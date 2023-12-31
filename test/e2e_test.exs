defmodule ElixirScript.E2eTest do
  @moduledoc """
  This module contains unit tests for the E2e module's functionality,
  ensuring that the test file reading and parsing behaviors are working as expected.
  """
  use ExUnit.Case
  import Mox

  alias ElixirScript.E2e
  alias Test.Fixtures.GitHubWorkflowRun

  setup :verify_on_exit!

  describe "read_test_file" do
    test "when providing a name it gets slugified" do
      file_path = create_temp_file([%{name: "Test name", script: ""}])
      result = E2e.read_test_file(file_path) |> List.first() |> Map.take([:name, :id])
      assert result == %{name: "Test name", id: "test-name"}
    end

    test "can read a simple example script" do
      file_path = create_temp_file([%{name: "Test name", script: "IO.puts(\"Hello, world!\")"}])
      result = E2e.read_test_file(file_path) |> List.first() |> Map.take([:file, :script])
      assert result == %{file: nil, script: "IO.puts(\"Hello, world!\")"}
    end

    test "can read an expected value" do
      file_path = create_temp_file([%{name: "Test name", script: "\"foo\"", expected: "foo"}])
      result = E2e.read_test_file(file_path) |> List.first() |> Map.take([:expected])
      assert result == %{expected: "foo"}
    end

    test "can read a file example" do
      file_path = create_temp_file([%{name: "Test name", file: "./foo.ex"}])
      result = E2e.read_test_file(file_path) |> List.first() |> Map.take([:file, :script])
      assert result == %{file: "./foo.ex", script: nil}
    end

    test "fails if neither script nor file is specified" do
      file_path = create_temp_file([%{name: "Test name"}])

      assert_raise KeyError, "key :script or :file not found in: %{name: \"Test name\"}", fn ->
        E2e.read_test_file(file_path)
      end
    end

    test "fails if name is not specified" do
      file_path = create_temp_file([%{script: ""}])

      assert_raise KeyError, "key :name not found in: %{script: \"\"}", fn ->
        E2e.read_test_file(file_path)
      end
    end
  end

  defp create_temp_file(content) do
    tmp_dir = System.tmp_dir()
    file_path = Path.join(tmp_dir, "temp.exs")
    File.write!(file_path, inspect(content))
    on_exit(fn -> File.rm!(file_path) end)
    file_path
  end
end

defmodule ElixirScript.E2eTest.EndToEndTest do
  @moduledoc """
  This module contains unit tests for the E2e module's functionality,
  ensuring that the test file reading and parsing behaviors are working as expected.
  """
  use ExUnit.Case
  import Mox

  alias ElixirScript.E2e
  alias ElixirScript.E2eTest.EndToEndUtils
  alias Test.Fixtures.GitHubWorkflowRun

  setup :verify_on_exit!

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "end-to-end tests" do
    test "run e2e tests", %{bypass: bypass} do
      ElixirScript.CustomLogger.configure(level: :debug)

      stub(SystemEnvMock, :get_env, fn varname, default ->
        GitHubWorkflowRun.env()[varname] || default
      end)

      Bypass.expect(bypass, "GET", "/users/gaggle", fn conn ->
        fixture_path = Path.join(__DIR__, "fixtures/api.github.com/users/gaggle/GET.200.json")
        Plug.Conn.resp(conn, 200, File.read!(fixture_path))
      end)

      Bypass.expect(bypass, "GET", "/repos/gaggle/elixir_script/stargazers", fn conn ->
        fixture_path =
          Path.join(
            __DIR__,
            "fixtures/api.github.com/repos/gaggle/elixir_script/stargazers/GET.200.json"
          )

        Plug.Conn.resp(conn, 200, File.read!(fixture_path))
      end)

      Bypass.expect(bypass, "PUT", "/user/starred/gaggle/elixir_script", fn conn ->
        Plug.Conn.resp(conn, 204, "")
      end)

      stub(TentacatMock.ClientMock, :new, fn ->
        Tentacat.Client.new("http://localhost:#{bypass.port}")
      end)

      E2e.read_test_file()
      |> Enum.each(&EndToEndUtils.run_test/1)
    end
  end
end

defmodule ElixirScript.E2eTest.EndToEndUtils do
  @moduledoc """
  This submodule focuses on running end-to-end tests and validating their output against expected results.
  """
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ElixirScript.E2e.Entry
  alias ElixirScript.ScriptRunner

  def run_test(%Entry{name: name, file: nil, script: script, expected: expected}) do
    {output, io} = run_script_and_capture_output(script)
    actual = convert_to_github_actions_output(output)

    unless is_nil(expected) do
      assert actual == expected,
             "E2E test '#{name}' failed.\n" <>
               "  EXPECTED:\n#{inspect(expected)}\n\n" <>
               "  ACTUAL:\n#{inspect(actual)}\n\n" <>
               "  LOGS:\n#{io}"
    end
  end

  # Runs the script and captures the return value by isolating it from other IO outputs.
  #
  # `ScriptRunner.run/1` executes a script that may produce additional output, such as logs.
  # To capture only the return value of the script, we spawn a new process that sends
  # the return value back to the parent process. This ensures that only the intended return
  # value is used for the test assertion, regardless of any other IO produced during script execution.
  defp run_script_and_capture_output(script) do
    io =
      capture_io(fn ->
        output = ScriptRunner.run(script)
        send(self(), {:output, output})
      end)

    assert_received {:output, output}
    {output, io}
  end

  # Converts the script output to match the GitHub Actions output format.
  #
  # In GitHub Actions, complex Elixir data structures are not automatically handled.
  # Instead, they are converted to strings, because they are transported via environment variables.
  #
  # This function takes the output and converts it into a string format that mirrors
  # the stringification behavior seen in GitHub Actions.
  #
  # Examples:
  #   - An Elixir list of atoms like `[:foo, :bar]` would be converted to `"[foo,bar]"`.
  #
  # @return A string that matches the expected output format of GitHub Actions.
  defp convert_to_github_actions_output(data) do
    case data do
      # Already a string, no change needed.
      binary when is_binary(binary) ->
        binary

      # Serialize the list as GitHub Actions would output it.
      list when is_list(list) ->
        list
        |> Enum.map_join(",", &convert_element_to_string/1)
        |> wrap_in_brackets()

      _ ->
        inspect(data)
        |> String.trim_leading("\"")
        |> String.trim_trailing("\"")
    end
  end

  defp convert_element_to_string(element) when is_atom(element), do: Atom.to_string(element)
  # For any non-atom elements.
  defp convert_element_to_string(element), do: element
  defp wrap_in_brackets(joined), do: "[#{joined}]"
end

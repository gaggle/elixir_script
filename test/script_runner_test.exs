defmodule ElixirScript.ScriptRunnerTest do
  use ExUnit.Case, async: true

  import Mox

  alias ElixirScript.ScriptRunner
  alias Test.Fixtures.GitHubWorkflowRun

  # Create a temporary file with automatic cleanup
  # Returns the full path to the created file
  defp create_temp_file(filename, content) do
    path = Path.join(System.tmp_dir(), filename)
    File.write!(path, content)
    on_exit(fn -> File.rm!(path) end)
    path
  end

  setup do
    stub(SystemEnvMock, :get_env, fn varname, default ->
      GitHubWorkflowRun.env()[varname] || default
    end)

    stub(TentacatMock.ClientMock, :new, fn -> %{auth: nil, endpoint: "github"} end)

    :ok
  end

  test "run executes script in a given context and returns its output" do
    script = """
    "Hello, " <> context.actor
    """

    assert ScriptRunner.run(script) == "Hello, gaggle"
  end

  test "run raises if the script raises an error" do
    script = """
    raise "error!"
    """

    assert_raise RuntimeError, "error!", fn ->
      ScriptRunner.run(script)
    end
  end

  describe "file-based scripts" do
    test "can execute scripts from file paths" do
      file_path = create_temp_file("test_script.exs", "\"Hello from test file\"")
      assert ScriptRunner.run(file_path) == "Hello from test file"
    end

    test "file scripts have access to context bindings" do
      file_path = create_temp_file("context_test.exs", ~S["Actor is: #{context.actor}"])
      assert ScriptRunner.run(file_path) == "Actor is: gaggle"
    end

    test "file scripts have access to client bindings" do
      file_path = create_temp_file("client_test.exs", "inspect(client)")
      result = ScriptRunner.run(file_path)
      assert result =~ "auth: nil"
    end

    test "auto-detects file paths vs inline scripts" do
      # Test detection by behavior - file paths cause File.Error
      assert_raise File.Error, fn ->
        ScriptRunner.run("./non_existent.exs")
      end

      assert_raise File.Error, fn ->
        ScriptRunner.run("../non_existent.exs")
      end

      assert_raise File.Error, fn ->
        ScriptRunner.run("/non_existent.exs")
      end

      # Inline scripts should be evaluated as code
      assert ScriptRunner.run("1 + 1") == 2
      assert ScriptRunner.run("\"hello\"") == "hello"
    end

    test "raises clear error when file doesn't exist" do
      assert_raise File.Error, ~r/no such file or directory/, fn ->
        ScriptRunner.run("./non_existent_file.exs")
      end
    end

    test "handles empty file gracefully" do
      file_path = create_temp_file("empty.exs", "")
      # Elixir naturally returns nil for empty files
      assert ScriptRunner.run(file_path) == nil
    end

    test "handles files returning nil" do
      file_path = create_temp_file("nil_return.exs", "IO.puts(\"side effect\")\nnil")
      assert ScriptRunner.run(file_path) == nil
    end

    test "works with any file extension containing valid Elixir code" do
      # .ex files work
      ex_file = create_temp_file("test.ex", "\"from .ex\"")
      assert ScriptRunner.run(ex_file) == "from .ex"

      # .txt files work if they contain Elixir
      txt_file = create_temp_file("test.txt", "\"from .txt\"")
      assert ScriptRunner.run(txt_file) == "from .txt"

      # No extension works too
      no_ext = create_temp_file("testfile", "\"no extension\"")
      assert ScriptRunner.run(no_ext) == "no extension"
    end

    test "gives helpful error for non-Elixir content" do
      file_path = create_temp_file("not_elixir.txt", "This is just plain text, not Elixir code")
      # Should get a syntax error with the filename in the message
      exception =
        assert_raise SyntaxError, fn ->
          ScriptRunner.run(file_path)
        end

      # The error includes the file path, helping users identify the problem
      assert exception.file =~ "not_elixir.txt"
    end

    test "preserves proper file semantics like __DIR__ and __ENV__" do
      file_path = create_temp_file("file_semantics.exs", "{__DIR__, __ENV__.file}")
      {dir, file} = ScriptRunner.run(file_path)

      # __DIR__ should be the directory containing the file
      assert dir == Path.dirname(Path.expand(file_path))

      # __ENV__.file should be the absolute path to the file
      assert file == Path.expand(file_path)
    end

    test "supports relative requires within files" do
      dir = Path.join(System.tmp_dir(), "require_test_#{:rand.uniform(1000)}")
      File.mkdir!(dir)

      helper_path = Path.join(dir, "my_helper.exs")
      File.write!(helper_path, "defmodule MyHelper do\n  def value, do: :from_helper\nend")

      main_path = Path.join(dir, "main.exs")
      File.write!(main_path, "Code.require_file(\"./my_helper.exs\", __DIR__)\nMyHelper.value()")

      on_exit(fn ->
        File.rm!(main_path)
        File.rm!(helper_path)
        File.rmdir!(dir)
      end)

      assert ScriptRunner.run(main_path) == :from_helper
    end
  end

  describe "github access" do
    test "executes with an un-authenticated Tentacat GitHub client by default" do
      expect(TentacatMock.ClientMock, :new, fn -> %{auth: nil, endpoint: "github"} end)

      assert ScriptRunner.run("true")
    end

    test "passes the Tentacat client into bindings" do
      expect(TentacatMock.ClientMock, :new, fn -> %{auth: nil, endpoint: "github"} end)

      assert ScriptRunner.run("client") == %{auth: nil, endpoint: "github"}
    end

    test "passes access token opts into the client, if available" do
      expect(TentacatMock.ClientMock, :new, fn %{access_token: token} ->
        %{auth: token, endpoint: "github"}
      end)

      opts = [github_token: "token"]
      assert ScriptRunner.run("client", opts) == %{auth: "token", endpoint: "github"}
    end
  end
end

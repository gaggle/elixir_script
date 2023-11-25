defmodule ElixirScript.ScriptRunnerTest do
  use ExUnit.Case, async: true

  import Mox

  alias ElixirScript.ScriptRunner
  alias Test.Fixtures.GitHubWorkflowRun

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

defmodule ElixirScript.ScriptRunnerTest do
  use ExUnit.Case, async: true

  import Mox

  alias ElixirScript.ScriptRunner
  alias Test.Fixtures.GitHubWorkflowRun

  setup do
    stub(SystemEnvMock, :get_env, fn varname, default ->
      GitHubWorkflowRun.env()[varname] || default
    end)

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
end

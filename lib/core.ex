defmodule ElixirScript.Core do
  @moduledoc """
  Provides core functionalities for ElixirScript,
  handling the retrieval and sanitization of GitHub Actions environment inputs and outputs.
  """

  alias ElixirScript.GitHubActions.EnvironmentFileCommand
  alias ElixirScript.GitHubActions.WorkflowCommand
  alias ElixirScript.GitHubActions.WorkflowCommandUtils

  def get_env_input(name, opts \\ []) do
    required = Keyword.get(opts, :required, false)
    trim_whitespace = Keyword.get(opts, :trim_whitespace, true)

    env_var_name = "INPUT_#{String.replace(name, " ", "_") |> String.upcase()}"
    val = System.get_env(env_var_name, "")

    cond do
      required && val == "" ->
        raise "Input '#{name}' required but not supplied in environment variable '#{env_var_name}'"

      trim_whitespace == false ->
        val

      true ->
        String.trim(val)
    end
  end

  def set_output(value, name) do
    if System.get_env("GITHUB_OUTPUT") do
      EnvironmentFileCommand.issue_file_command(
        "OUTPUT",
        EnvironmentFileCommand.prepare_key_value_message(
          name,
          WorkflowCommandUtils.to_command_value(value)
        )
      )
    else
      WorkflowCommand.issue_command(
        ~c"set-output",
        name,
        WorkflowCommandUtils.to_command_value(value)
      )
    end
  end

  def log_output do
    if System.get_env("GITHUB_OUTPUT") do
      EnvironmentFileCommand.log_output()
    end
  end
end

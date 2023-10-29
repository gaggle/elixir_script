defmodule ElixirScript.Core do
  alias ElixirScript.GitHubActions.Command
  alias ElixirScript.GitHubActions.CommandUtils
  alias ElixirScript.GitHubActions.EnvironmentFileCommand

  def parse_args(args) do
    aliases = [script: :s, debug: :d]
    parsed = OptionParser.parse(args, aliases: aliases)

    case parsed do
      {opts, _remaining_args, _invalid_opts} ->
        %{script: Map.get(opts, :script), debug: Map.get(opts, :debug)}
    end
  end

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
        EnvironmentFileCommand.prepare_key_value_message(name, CommandUtils.to_command_value(value))
      )
    else
      Command.issue_command('set-output', name, CommandUtils.to_command_value(value))
    end
  end
end

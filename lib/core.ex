defmodule ElixirScript.Core do
  alias ElixirScript.FileCommand

  def get_input(name, opts \\ []) do
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

  def set_output(name, value) do
    FileCommand.issue_file_command("OUTPUT", FileCommand.prepare_key_value_message(name, value))
  end
end

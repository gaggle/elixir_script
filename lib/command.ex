defmodule ElixirScript.Command do
  alias ElixirScript.CommandUtils

  def issue_command(command, name, command_value) do
    IO.puts("::#{command} name=#{name}::#{command_value}")
  end
end

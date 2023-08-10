defmodule ElixirScript.CommandUtils do
  def to_command_value(nil), do: ""

  def to_command_value(input) when is_binary(input), do: input
end

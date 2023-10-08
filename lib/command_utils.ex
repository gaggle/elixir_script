defmodule ElixirScript.CommandUtils do

  def to_command_value(nil), do: ""

  def to_command_value(input) when is_binary(input), do: input

  def to_command_value(input), do: Jason.encode!(input)
end

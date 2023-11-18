defmodule ElixirScript.GitHubActions.WorkflowCommandUtils do
  @moduledoc """
  Utility functions for converting a a string format compatible with GitHub Actions commands.
  This includes handling `nil` values, binary strings, and encoding complex data types into JSON strings.
  """

  def to_command_value(nil), do: ""

  def to_command_value(input) when is_binary(input), do: input

  def to_command_value(input), do: Jason.encode!(input)
end

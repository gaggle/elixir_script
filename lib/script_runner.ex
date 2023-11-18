defmodule ElixirScript.ScriptRunner do
  @moduledoc """
  Executes dynamic Elixir script content, allowing for the execution of arbitrary code snippets.
  """
  alias ElixirScript.Context

  def run(script) do
    {value, _binding} = Code.eval_string(script, context: Context.from_github_environment())
    value
  end
end

defmodule ElixirScript.ScriptRunner do
  alias ElixirScript.Context

  def run(script) do
    {value, _binding} = Code.eval_string(script, context: Context.from_github_environment())
    value
  end
end

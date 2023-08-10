defmodule ElixirScript.CLI do
  alias ElixirScript.Context
  alias ElixirScript.Core

  def main(_args \\ []) do
    script = Core.get_input("script", required: true)
    {value, _binding} = Code.eval_string(script, context: Context.from_github_environment())
    Core.set_output("result", value)
  end
end

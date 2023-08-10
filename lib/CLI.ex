defmodule ElixirScript.CLI do
  alias ElixirScript.Core

  def main(_args \\ []) do
    script = Core.get_input("script", required: true)
    {value, _binding} = Code.eval_string(script)
    Core.set_output("result", value)
  end
end

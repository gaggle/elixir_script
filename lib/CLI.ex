defmodule ElixirScript.CLI do
  alias ElixirScript.Context
  alias ElixirScript.Core
  alias ElixirScript.CustomLogger, as: Logger

  def main(_args \\ []) do
    Logger.debug("Running in debug mode")
    Logger.debug("All Environment Variables: #{inspect(System.get_env(), limit: :infinity, printable_limit: :infinity)}")

    script = Core.get_env_input("script", required: true)
    Logger.debug("Script input: #{inspect(script, limit: :infinity, printable_limit: :infinity)}")

    {value, _binding} = Code.eval_string(script, context: Context.from_github_environment())
    Core.set_output("result", value)
    Logger.debug("Result output: #{inspect(value, limit: :infinity, printable_limit: :infinity)}")
  end

  defp log_debug(message) do
    if @debug_mode, do: Logger.debug(message)
  end
end

defmodule ElixirScript.CommandLine do
  alias ElixirScript.Context
  alias ElixirScript.Core
  alias ElixirScript.CustomLogger, as: Logger

  def main(args \\ []) do
    Logger.debug("Running in debug mode")
    {opts, _, _} = OptionParser.parse(args, strict: [help: :boolean])

    if opts[:help] do
      print_help()
    else
      run_script()
    end
  end

  defp run_script do
    Logger.debug("All Environment Variables: #{inspect(System.get_env(), limit: :infinity, printable_limit: :infinity)}")

    script = Core.get_env_input("script", required: true)
    Logger.debug("Script input: #{inspect(script, limit: :infinity, printable_limit: :infinity)}")

    {value, _binding} = Code.eval_string(script, context: Context.from_github_environment())
    Core.set_output("result", value)
    Logger.debug("Result output: #{inspect(value, limit: :infinity, printable_limit: :infinity)}")
  end

  defp print_help do
    IO.puts("""
    Usage:
      script [OPTIONS]

    Options:
      --help          Show this help message and exit.

    Example:
      INPUT_SCRIPT="IO.puts('Hello, world!')" script
    """)
  end
end

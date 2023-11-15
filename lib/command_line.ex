defmodule ElixirScript.CommandLine do
  alias ElixirScript.Core
  alias ElixirScript.CustomLogger, as: Logger
  alias ElixirScript.ScriptRunner

  def main(args \\ []) do
    Logger.debug("Running in debug mode")

    Logger.debug(
      "All Environment Variables: #{inspect(System.get_env(), limit: :infinity, printable_limit: :infinity)}"
    )

    {opts, _, _} = OptionParser.parse(args, strict: [help: :boolean])
    Logger.debug("Parsed options: #{inspect(opts, limit: :infinity, printable_limit: :infinity)}")

    if opts[:help] do
      print_help()
    else
      result = ScriptRunner.run(get_script())
      Core.set_output(result, "result")

      Logger.debug(
        "Result output: #{inspect(result, limit: :infinity, printable_limit: :infinity)}"
      )
    end
  end

  defp get_script do
    script = Core.get_env_input("script", required: true)
    Logger.debug("Script input: #{inspect(script, limit: :infinity, printable_limit: :infinity)}")
    script
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

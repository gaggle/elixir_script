defmodule ElixirScript.CommandLine do
  @moduledoc """
  Main entrypoint for ElixirScript.
  Manages the parsing of command-line arguments, configures logger, and delegates work into sub-systems.
  """

  alias ElixirScript.Core
  alias ElixirScript.CustomLogger, as: Logger
  alias ElixirScript.ScriptRunner

  defmodule ParsedArgs do
    @moduledoc """
    Struct for parsed args
    """
    defstruct debug?: false, help?: false, script: nil
  end

  def main(args, opts \\ []) do
    parsed_args = parse_args!(args)
    log_level = if parsed_args.debug?, do: :debug, else: :info
    Logger.configure(level: log_level)

    runner = Keyword.get(opts, :runner, &ScriptRunner.run/1)
    Logger.debug("Running in debug mode, using runner: #{inspect(runner)}")

    Logger.debug("Environment Variables: #{inf_inspect(System.get_env())}")

    Logger.debug("Parsed args: #{inf_inspect(parsed_args)}")

    if parsed_args.help? do
      print_help()
      System.halt(0)
    else
      Logger.debug("Script input: #{inf_inspect(parsed_args.script)}")
      result = runner.(parsed_args.script)
      Core.set_output(result, "result")
      Logger.debug("Result output: #{inspect(result, pretty: true)}")
    end
  end

  def parse_args!(args) do
    {parsed, _remaining_args} =
      OptionParser.parse!(args,
        strict: [script: :string, debug: :boolean, help: :boolean],
        aliases: [debug: :d, help: :h, script: :s]
      )

    debug? = Keyword.get(parsed, :debug, System.get_env("INPUT_DEBUG") == "true")
    script = Keyword.get(parsed, :script, System.get_env("INPUT_SCRIPT"))
    help? = Keyword.get(parsed, :help, false)

    %ParsedArgs{
      debug?: debug?,
      help?: help?,
      script: script
    }
  end

  defp print_help do
    IO.puts("""
    Usage:
      script [OPTIONS]

    Options:
      --script,-s       Specifies the script to run [INPUT_SCRIPT]
      --debug, -d       Enables debug mode [INPUT_DEBUG]
      --help, -h        Show this help message and exit

    Example:
      script --script "IO.puts('Hello, world!')"
    """)
  end

  def inf_inspect(exec) do
    inspect(exec, pretty: true, limit: :infinity, printable_limit: :infinity)
  end
end

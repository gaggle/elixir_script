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
    defstruct debug?: false, gh_token: nil, help?: false, script: nil
  end

  def main(args) do
    parsed_args = parse_args!(args)
    log_level = if parsed_args.debug?, do: :debug, else: :info
    Logger.configure(level: log_level)

    runner = script_runner()
    Logger.debug("Running in debug mode, using runner: #{inspect(runner)}")

    Logger.debug("Environment Variables: #{inf_inspect(System.get_env())}")

    Logger.debug("Parsed args: #{inf_inspect(parsed_args)}")

    if parsed_args.help? do
      print_help()
      System.halt(0)
    else
      Logger.debug("Script input: #{inf_inspect(parsed_args.script)}")
      result = runner.run(parsed_args.script, github_token: parsed_args.gh_token)
      Core.set_output(result, "result")
      Logger.debug("Result output: #{inspect(result, pretty: true)}")
    end
  end

  def parse_args!(args) do
    {parsed, _remaining_args} =
      OptionParser.parse!(args,
        strict: [script: :string, gh_token: :string, debug: :boolean, help: :boolean],
        aliases: [d: :debug, h: :help, s: :script]
      )

    debug? = Keyword.get(parsed, :debug, System.get_env("INPUT_DEBUG") == "true")
    gh_token = Keyword.get(parsed, :gh_token, System.get_env("GH_TOKEN"))
    help? = Keyword.get(parsed, :help, false)
    script = Keyword.get(parsed, :script, System.get_env("INPUT_SCRIPT"))

    %ParsedArgs{
      debug?: debug?,
      gh_token: gh_token,
      help?: help?,
      script: script
    }
  end

  defp print_help do
    IO.puts("""
    Usage:
      script [OPTIONS]

    Options:
      --script, -s       Specifies the script to run [INPUT_SCRIPT]
      --gh-token         The GitHub Token to use for the Tentacat client [GH_TOKEN]
      --debug,  -d       Enables debug mode [INPUT_DEBUG]
      --help,   -h       Show this help message and exit

    Example:
      script --script "IO.puts('Hello, world!')"
    """)
  end

  def inf_inspect(exec) do
    inspect(exec, pretty: true, limit: :infinity, printable_limit: :infinity)
  end

  defp script_runner,
    do: Application.get_env(:command_line, :script_runner, ScriptRunner)
end

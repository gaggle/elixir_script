defmodule ElixirScript.ScriptRunnerBehaviour do
  @moduledoc """
  Abstract behaviour of ScriptRunner.
  """
  @callback run(script :: String.t(), opts :: Keyword.t()) :: any()
end

defmodule ElixirScript.ScriptRunner do
  @moduledoc """
  Executes dynamic Elixir script content, allowing for the execution of arbitrary code snippets.
  """
  @behaviour ElixirScript.ScriptRunnerBehaviour

  alias ElixirScript.Context
  alias ElixirScript.CustomLogger, as: Logger

  @impl ElixirScript.ScriptRunnerBehaviour
  def run(script, opts \\ []) do
    token = Keyword.get(opts, :github_token)

    client =
      if token != nil,
        do: tentacat_client().new(%{access_token: token}),
        else: tentacat_client().new()

    Logger.debug("Created GitHub client: #{inspect(client)}")

    bindings = [
      context: Context.from_github_environment(),
      client: client
    ]

    {value, _binding} =
      if is_file_path?(script) do
        path = Path.expand(script)
        content = File.read!(path)
        Code.eval_string(content, bindings, file: path, line: 1)
      else
        Code.eval_string(script, bindings)
      end

    value
  end

  # Determines if the given string is a file path
  defp is_file_path?(script) when is_binary(script) do
    String.starts_with?(script, ["./", "../", "/"])
  end

  defp tentacat_client, do: Application.get_env(:script_runner, :tentacat_client, Tentacat.Client)
end

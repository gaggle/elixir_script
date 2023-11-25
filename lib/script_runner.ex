defmodule ElixirScript.ScriptRunnerBehaviour do
  @callback run(script :: String.t(), opts :: Keyword.t()) :: any()
end

defmodule ElixirScript.ScriptRunner do
  @moduledoc """
  Executes dynamic Elixir script content, allowing for the execution of arbitrary code snippets.
  """
  @behaviour ElixirScript.ScriptRunnerBehaviour

  alias ElixirScript.Context

  @impl ElixirScript.ScriptRunnerBehaviour
  def run(script, opts \\ []) do
    token = Keyword.get(opts, :github_token)

    client =
      if token != nil,
        do: tentacat_client().new(%{access_token: token}),
        else: tentacat_client().new()

    {value, _binding} =
      Code.eval_string(
        script,
        context: Context.from_github_environment(),
        client: client
      )

    value
  end

  defp tentacat_client, do: Application.get_env(:script_runner, :tentacat_client, Tentacat.Client)
end

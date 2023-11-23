defmodule ElixirScript.Context do
  @moduledoc """
  Constructs a structured context of the GitHub Actions environment variables, for use within ElixirScript.
  """
  alias __MODULE__

  @derive Jason.Encoder
  defstruct [
    :payload,
    :event_name,
    :sha,
    :ref,
    :workflow,
    :action,
    :actor,
    :job,
    :run_number,
    :run_id,
    :api_url,
    :server_url,
    :graphql_url
  ]

  def from_github_environment do
    %Context{
      payload: read_payload(),
      event_name: get_env("GITHUB_EVENT_NAME", ""),
      sha: get_env("GITHUB_SHA", ""),
      ref: get_env("GITHUB_REF", ""),
      workflow: get_env("GITHUB_WORKFLOW", ""),
      action: get_env("GITHUB_ACTION", ""),
      actor: get_env("GITHUB_ACTOR", ""),
      job: get_env("GITHUB_JOB", ""),
      run_number: get_env("GITHUB_RUN_NUMBER") |> parse_int(),
      run_id: get_env("GITHUB_RUN_ID") |> parse_int(),
      api_url: get_env("GITHUB_API_URL", "https://api.github.com"),
      server_url: get_env("GITHUB_SERVER_URL", "https://github.com"),
      graphql_url: get_env("GITHUB_GRAPHQL_URL", "https://api.github.com/graphql")
    }
  end

  defp read_payload do
    get_env("GITHUB_EVENT_PATH") |> maybe_read_file(keys: :atoms)
    # ↑ The GitHub event is a well-defined data-structure, it's fine to keep as atoms.
  end

  defp maybe_read_file(nil, _), do: %{}

  defp maybe_read_file(path, opts) do
    case File.read(path) do
      {:ok, contents} ->
        contents |> Jason.decode!(opts)

      {:error, _reason} ->
        IO.puts("Error reading GITHUB_EVENT_PATH #{path}")
        %{}
    end
  end

  defp get_env(var, default \\ nil), do: system_env_impl().get_env(var, default)

  defp parse_int(nil), do: nil
  defp parse_int(value), do: String.to_integer(value)

  defp system_env_impl, do: Application.get_env(:context, :system_env, System)
end

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
      event_name: fetch_env("GITHUB_EVENT_NAME", ""),
      sha: fetch_env("GITHUB_SHA", ""),
      ref: fetch_env("GITHUB_REF", ""),
      workflow: fetch_env("GITHUB_WORKFLOW", ""),
      action: fetch_env("GITHUB_ACTION", ""),
      actor: fetch_env("GITHUB_ACTOR", ""),
      job: fetch_env("GITHUB_JOB", ""),
      run_number: fetch_env("GITHUB_RUN_NUMBER"),
      run_id: fetch_env("GITHUB_RUN_ID") |> parse_int(),
      api_url: fetch_env("GITHUB_API_URL", "https://api.github.com"),
      server_url: fetch_env("GITHUB_SERVER_URL", "https://github.com"),
      graphql_url: fetch_env("GITHUB_GRAPHQL_URL", "https://api.github.com/graphql")
    }
  end

  defp read_payload do
    fetch_env("GITHUB_EVENT_PATH")
    |> maybe_read_file()
  end

  defp maybe_read_file(nil), do: %{}

  defp maybe_read_file(path) do
    case File.read(path) do
      {:ok, contents} ->
        contents |> Jason.decode!()

      {:error, _reason} ->
        IO.puts("Error reading GITHUB_EVENT_PATH #{path}")
        %{}
    end
  end

  defp fetch_env(var), do: System.get_env(var)
  defp fetch_env(var, default), do: fetch_env(var) || default

  defp parse_int(nil), do: nil
  defp parse_int(value), do: String.to_integer(value)
end

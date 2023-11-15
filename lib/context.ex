defmodule ElixirScript.Context do
  alias __MODULE__

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

  defimpl Jason.Encoder, for: Context do
    def encode(%Context{} = context, opts) do
      Map.from_struct(context) |> Jason.Encode.map(opts)
    end
  end

  def from_github_environment() do
    payload =
      if System.get_env("GITHUB_EVENT_PATH") do
        path = System.get_env("GITHUB_EVENT_PATH")

        if File.exists?(path) do
          File.read!(path) |> Jason.decode!()
        else
          IO.puts("GITHUB_EVENT_PATH #{path} does not exist")
          %{}
        end
      else
        %{}
      end

    %Context{
      payload: payload,
      event_name: System.get_env("GITHUB_EVENT_NAME") || "",
      sha: System.get_env("GITHUB_SHA") || "",
      ref: System.get_env("GITHUB_REF") || "",
      workflow: System.get_env("GITHUB_WORKFLOW") || "",
      action: System.get_env("GITHUB_ACTION") || "",
      actor: System.get_env("GITHUB_ACTOR") || "",
      job: System.get_env("GITHUB_JOB") || "",
      run_number: System.get_env("GITHUB_RUN_NUMBER") |> parse_int(),
      run_id: System.get_env("GITHUB_RUN_ID") |> parse_int(),
      api_url: System.get_env("GITHUB_API_URL") || "https://api.github.com",
      server_url: System.get_env("GITHUB_SERVER_URL") || "https://github.com",
      graphql_url: System.get_env("GITHUB_GRAPHQL_URL") || "https://api.github.com/graphql"
    }
  end

  defp parse_int(nil), do: nil
  defp parse_int(value), do: String.to_integer(value)
end

[
  %{
    name: "Scripts are run, and what it returns is available via outputs",
    script: """
      defmodule Foo do
        def bar, do: "bar"
      end
      Foo.bar()
    """,
    expected: "bar"
  },
  %{
    name: "IO is visible in logs",
    script: "IO.puts(\"Hello world\")"
  },
  %{
    name: "Event context is available",
    script: "Map.keys(context) |> Enum.sort",
    expected:
      "[__struct__,action,actor,api_url,event_name,graphql_url,job,payload,ref,run_id,run_number,server_url,sha,workflow]"
  }
]

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
    script: """
    IO.puts("Hello world")
    """
  },
  %{
    name: "Event context is available",
    script: """
    IO.inspect(context)
    Map.keys(context) |> Enum.sort
    """,
    expected:
      "[__struct__,action,actor,api_url,event_name,graphql_url,job,payload,ref,run_id,run_number,server_url,sha,workflow]"
  },
  %{
    name: "The entire context can be inspected",
    script: "IO.inspect(context, pretty: true, limit: :infinity, printable_limit: :infinity)"
  },
  %{
    name: "Multiline scripts are possible",
    script: """
    IO.puts("Hello world")
    "result"
    """
  },
  %{
    name: "Oh hi Mark Greeter",
    script: """
      defmodule Greeter do
        def greet(name), do: "Oh hi \#{name}!"
      end
      Greeter.greet("Mark")
    """,
    expected: "Oh hi Mark!"
  },
  %{
    name: "Can use the GitHub API via Tentacat",
    script: """
      {200, user, _} = Tentacat.Users.find(client, "gaggle")
      get_in(user, ["login"])
    """,
    expected: "gaggle"
  },
  %{
    name: "Can grab information via the GitHub API",
    script: """
      {200, stargazers, _} = Tentacat.Users.Starring.stargazers(client, "gaggle", "elixir_script")
      IO.inspect(Enum.map_join(stargazers, ", ", & &1["login"]), label: "Stargazers")
    """
  },
  %{
    name: "Can interact with repositories via GitHub API",
    script: """
      {204, _, _} = Tentacat.Users.Starring.star(client, "gaggle", "elixir_script")
      :ok
    """
  }
]

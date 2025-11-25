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
  },
  %{
    name: "File scripts can define and use modules",
    script: "./.github/scripts/pr_analyzer.exs",
    file_content: %{
      "./.github/scripts/pr_analyzer.exs" => """
      defmodule PRAnalyzer do
        def analyze(context) do
          %{
            event: context.event_name,
            workflow: context.workflow,
            job: context.job,
            ref: context.ref
          }
        end

        def format_message(analysis) do
          "PR Analysis: event=\#{analysis.event}"
        end
      end

      # Use the module to analyze and format
      analysis = PRAnalyzer.analyze(context)
      PRAnalyzer.format_message(analysis)
      """
    },
    expected: "PR Analysis: event=push"
  },
  %{
    name: "File scripts can use relative require for helper modules",
    script: "./scripts/main.exs",
    file_content: %{
      "./scripts/helpers.exs" => """
      defmodule Helpers do
        def format_workflow(_context) do
          "Script loaded from: ./scripts/main.exs"
        end
      end
      """,
      "./scripts/main.exs" => """
      Code.require_file("helpers.exs", __DIR__)
      Helpers.format_workflow(context)
      """
    },
    expected: "Script loaded from: ./scripts/main.exs"
  },
  %{
    name: "Bootstrap pattern delegates to testable module",
    script: """
    # Bootstrap: load and run the main module
    Code.require_file("main.ex", ".")
    Main.run(context)
    """,
    file_content: %{
      "main.ex" => """
      defmodule Main do
        def run(_context) do
          "Bootstrap test passed!"
        end
      end
      """
    },
    expected: "Bootstrap test passed!"
  },
  %{
    name: "Bootstrap with complex module structure",
    script: """
    # Minimal bootstrap that loads and runs the application
    Code.require_file("lib/analyzer.ex", ".")
    Code.require_file("lib/formatter.ex", ".")
    Code.require_file("lib/app.ex", ".")
    App.start(context, client)
    """,
    file_content: %{
      "lib/analyzer.ex" => """
      defmodule Analyzer do
        def analyze_event(context) do
          %{
            type: context.event_name,
            branch: extract_branch(context.ref)
          }
        end

        defp extract_branch(ref) do
          ref |> String.split("/") |> List.last()
        end
      end
      """,
      "lib/formatter.ex" => """
      defmodule Formatter do
        def format_analysis(analysis) do
          "Event type: \#{String.capitalize(analysis.type)}"
        end
      end
      """,
      "lib/app.ex" => """
      defmodule App do
        def start(context, _client) do
          context
          |> Analyzer.analyze_event()
          |> Formatter.format_analysis()
        end
      end
      """
    },
    expected: "Event type: Push"
  }
]

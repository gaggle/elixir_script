defmodule ElixirScript.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_script,
      version: "0.1.0",
      elixir: "~> 1.15",
      escript: escript(),
      deps: deps()
    ]
  end

  def escript do
    [
      main_module: ElixirScript.CLI
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

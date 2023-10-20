defmodule ElixirScript.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_script,
      version: "0.0.0",
      elixir: "~> 1.15",
      escript: escript(),
      deps: deps()
    ]
  end

  def escript do
    [
      main_module: ElixirScript.CommandLine
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:jason, "~> 1.4"}]
  end
end

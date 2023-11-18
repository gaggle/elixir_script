defmodule ElixirScript.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_script,
      version: "0.0.0",
      elixir: "~> 1.15",
      escript: escript(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def escript do
    [
      main_module: ElixirScript.CommandLine
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end

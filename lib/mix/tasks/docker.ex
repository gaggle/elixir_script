defmodule Mix.Tasks.Docker do
  use Mix.Task

  @shortdoc "Manages Docker operations for the project."

  def run(args) do
    case args do
      ["build"] -> build()
      _ -> Mix.raise("Usage: mix docker build")
    end
  end

  defp build do
    System.cmd("docker", [
      "build",
      "--progress",
      "plain",
      "--tag",
      "elixir_script:latest",
      "-f",
      ".github/Dockerfile",
      "."
    ])
  end
end

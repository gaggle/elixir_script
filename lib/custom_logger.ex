defmodule ElixirScript.CustomLogger do
  @moduledoc """
  A custom logger module suitable for GitHub Actions' debug mode.
  """

  def debug(message) do
    if debug_mode?(), do: log(:debug, message)
  end

  defp debug_mode?() do
    System.get_env("INPUT_DEBUG") == "true"
  end

  defp log(level, message) do
    IO.puts("[#{level}] #{message}")
  end
end

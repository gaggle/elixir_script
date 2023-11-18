defmodule ElixirScript.CustomLogger do
  @moduledoc """
  A custom logger module suitable for GitHub Actions' debug mode.
  """

  def debug(message) do
    if debug_mode?(), do: log(:debug, message)
  end

  def configure(opts \\ []) do
    level = Keyword.get(opts, :level, :info)
    Application.put_env(:elixir_script, :log_level, level)
  end

  defp debug_mode? do
    Application.get_env(:elixir_script, :log_level, :info) == :debug
  end

  defp log(level, message) do
    IO.puts("[#{level}] #{message}")
  end
end

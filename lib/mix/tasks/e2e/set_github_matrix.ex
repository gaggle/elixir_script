defmodule Mix.Tasks.E2e.SetGithubMatrix do
  @moduledoc """
  Mix task to generate matrix information from E2E test data for GitHub Actions workflows.
  """
  use Mix.Task

  alias ElixirScript.Core
  alias ElixirScript.E2e
  alias ElixirScript.E2e.Entry

  def run(args) do
    output_key = List.first(args) || "matrix"

    E2e.read_test_file()
    |> log_detected_tests()
    |> map_entries_for_json()
    |> encode_for_github_actions()
    |> Core.set_output(output_key)

    Core.log_output()
  end

  # Logs the detected E2E tests to the console.
  defp log_detected_tests(entries) do
    IO.puts("E2E tests found:")
    Enum.each(entries, &log_test_entry/1)
    # Return the unchanged list of entries
    entries
  end

  # Logs a single E2E test entry.
  defp log_test_entry(entry) do
    IO.puts("  * \"#{entry.name}\"")
  end

  # Converts a list of `Entry` structs into a list of maps suitable for JSON encoding.
  defp map_entries_for_json(entries) do
    Enum.map(entries, &entry_to_map_for_json/1)
  end

  # Converts an `Entry` struct to a map for JSON encoding.
  defp entry_to_map_for_json(%Entry{} = entry) do
    Map.take(entry, [:name, :script, :expected, :file_content])
  end

  # Encodes the provided entries into a JSON structure for GitHub Actions matrix.
  defp encode_for_github_actions(entries) do
    %{"include" => entries}
    |> Jason.encode!()
  end
end

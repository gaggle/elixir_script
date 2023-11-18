defmodule Mix.Tasks.E2e.UpdateExamplesWorkflow do
  use Mix.Task
  alias ElixirScript.E2e
  alias ElixirScript.E2e.Entry

  @shortdoc "Updates the examples workflow. Use --check to fail if file needs updating"

  @workflow_file ".github/workflows/examples.yml"

  @spec run([String.t()]) :: :ok
  def run(args) do
    check_only? = "--check" in args
    new_content = E2e.read_test_file() |> generate_workflow()

    case read_workflow_file() do
      {:ok, current_content} when current_content == new_content ->
        Mix.shell().info("Workflow file is up to date")

      {:ok, _} when check_only? ->
        Mix.raise(
          "Workflow file is not up to date. Run `mix e2e.update_examples_workflow` to update it"
        )

      {:ok, _} ->
        # If file exists but content is different, write the new content
        write_workflow_file(new_content)
        Mix.shell().info("Workflow file updated")

      {:error, :enoent} when check_only? ->
        # If file doesn't exist and check_only is true, raise an error
        Mix.raise(
          "Workflow file does not exist. Run `mix e2e.update_examples_workflow` to create it"
        )

      {:error, :enoent} ->
        # If file doesn't exist, write the new content as a new file
        write_workflow_file(new_content)
        Mix.shell().info("Workflow file created")

      {:error, reason} ->
        # Handle other errors
        Mix.raise("Failed to read workflow file: #{reason}")
    end
  end

  def read_workflow_file do
    File.read(@workflow_file)
  end

  def write_workflow_file(content) do
    File.write!(@workflow_file, content)
  end

  def generate_workflow(entries) do
    jobs =
      Enum.map(entries, fn entry -> generate_job(entry) end)
      |> Enum.join("\n")
      |> indent_string(2)

    """
    # CI output from these examples are available here:
    # https://github.com/gaggle/elixir_script/actions/workflows/examples.yml?query=branch%3Amain
    #
    # ℹ️ This file is automatically generated via `mix e2e.update_examples_workflow`

    name: Examples

    on:
      push:
        paths:
          - .github/workflows/examples.yml
      release:
        types:
          - "created"
      workflow_dispatch:

    jobs:
    """ <> jobs
  end

  defp generate_job(%Entry{} = entry) do
    pre_indented_script_lines = entry.script |> String.trim_trailing |> dedent_string |> indent_string(10)
    #                                           ↑
    # No trailing empty lines because we tightly control how script-lines are placed within the template
    #                                                                                                  ↑↑
    # In the job template below "script" is indented 8, so the script itself needs 10 indents

    """
    #{entry.id}:
      runs-on: ubuntu-latest
      steps:
        - uses: gaggle/elixir_script@v0
          id: script
          with:
            script: |
    #{pre_indented_script_lines}

        - name: Get result
          run: echo "\${{steps.script.outputs.result}}"
    """
  end

  @spec indent_string(String.t(), non_neg_integer()) :: String.t()
  defp indent_string(str, indent) do
    indentation = String.duplicate(" ", indent)

    str
    |> String.split(~r/\n/)
    |> Enum.map(fn
      line ->
        case String.trim(line) do
          "" -> line
          _ -> indentation <> line
        end
    end)
    |> Enum.join("\n")
  end

  @spec dedent_string(String.t()) :: String.t()
  defp dedent_string(str) do
    lines = String.split(str, "\n")
    smallest_indent =
      lines
      |> Enum.reject(&String.trim(&1) == "") # Ignore empty or whitespace-only lines
      |> Enum.map(&String.length(Regex.replace(~r/^(\s*).*$/, &1, "\\1")))
      |> Enum.min()
      |> Kernel.||(0) # Default to 0 if the list is empty

    lines
    |> Enum.map(fn line ->
      slice_length = Enum.min([String.length(line), smallest_indent])
      String.slice(line, slice_length..-1)
    end)
    |> Enum.join("\n")
  end
end

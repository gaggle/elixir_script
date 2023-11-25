defmodule Mix.Tasks.E2e.UpdateExamplesWorkflowTest do
  use ExUnit.Case, async: true

  alias ElixirScript.E2e.Entry
  alias Mix.Tasks.E2e.UpdateExamplesWorkflow

  describe "generate_workflow/1" do
    test "generates workflow content from entries" do
      entry = %Entry{
        id: "io-visible-in-logs-and-return-value-available-via-outputs",
        script: """
        IO.puts("Hello world")
        "return"
        """
      }

      actual_output = UpdateExamplesWorkflow.generate_workflow([entry])

      expected_output =
        """
        # CI output from these examples are available here:
        # https://github.com/gaggle/elixir_script/actions/workflows/examples.yml?query=branch%3Amain
        #
        # ℹ️ This file is automatically generated via `mix e2e.update_examples_workflow`

        name: Examples

        on:
          push:
            branches: [ 'main' ]
            paths:
              - .github/workflows/examples.yml
          release:
            types:
              - "created"
          workflow_dispatch:

        env:
          GH_TOKEN: ${{ secrets.PAT }}

        jobs:
          io-visible-in-logs-and-return-value-available-via-outputs:
            runs-on: ubuntu-latest
            steps:
              - uses: gaggle/elixir_script@v0
                id: script
                with:
                  script: |
                    IO.puts("Hello world")
                    "return"

              - name: Get result
                run: echo "${{steps.script.outputs.result}}"
        """

      assert_multiline_string_equality(actual_output, expected_output)
    end

    test "can handle poorly-indented script" do
      entry = %Entry{
        id: "io-visible-in-logs-and-return-value-available-via-outputs",
        script: """
          defmodule Foo do
            def bar, do: "bar"
          end
          Foo.bar()
        """
      }

      actual_output = UpdateExamplesWorkflow.generate_workflow([entry])

      expected_output =
        """
        # CI output from these examples are available here:
        # https://github.com/gaggle/elixir_script/actions/workflows/examples.yml?query=branch%3Amain
        #
        # ℹ️ This file is automatically generated via `mix e2e.update_examples_workflow`

        name: Examples

        on:
          push:
            branches: [ 'main' ]
            paths:
              - .github/workflows/examples.yml
          release:
            types:
              - "created"
          workflow_dispatch:

        env:
          GH_TOKEN: ${{ secrets.PAT }}

        jobs:
          io-visible-in-logs-and-return-value-available-via-outputs:
            runs-on: ubuntu-latest
            steps:
              - uses: gaggle/elixir_script@v0
                id: script
                with:
                  script: |
                    defmodule Foo do
                      def bar, do: "bar"
                    end
                    Foo.bar()

              - name: Get result
                run: echo "${{steps.script.outputs.result}}"
        """

      assert_multiline_string_equality(actual_output, expected_output)
    end
  end

  defp assert_multiline_string_equality(actual, expected) do
    unless actual == expected do
      IO.puts("Actual:\n#{actual}")
      IO.puts("Expected:\n#{expected}")
    end

    assert actual == expected
  end
end

defmodule ElixirScript.CommandLineTest do
  use ExUnit.Case, async: false

  alias ElixirScript.CommandLine

  describe "parse_args!/1" do
    @script "IO.puts('Hello, world!')"
    @default_parsed_args %CommandLine.ParsedArgs{debug?: false, help?: false, script: nil}

    test "returns default ParsedArgs when no arguments are provided" do
      args = []
      assert CommandLine.parse_args!(args) == @default_parsed_args
    end

    test "parses --script argument correctly" do
      args = ["--script", @script]
      expected = %{@default_parsed_args | script: @script}
      assert CommandLine.parse_args!(args) == expected
    end

    test "parses -s (script alias) argument correctly" do
      args = ["-s", @script]
      expected = %{@default_parsed_args | script: @script}
      assert CommandLine.parse_args!(args) == expected
    end

    test "parses --debug argument correctly" do
      args = ["--debug"]
      expected = %{@default_parsed_args | debug?: true}
      assert CommandLine.parse_args!(args) == expected
    end

    test "parses -d (debug alias) argument correctly" do
      args = ["-d"]
      expected = %{@default_parsed_args | debug?: true}
      assert CommandLine.parse_args!(args) == expected
    end

    test "parses --help argument correctly" do
      args = ["--help"]
      expected = %{@default_parsed_args | help?: true}
      assert CommandLine.parse_args!(args) == expected
    end

    test "parses -h (help alias) argument correctly" do
      args = ["-h"]
      expected = %{@default_parsed_args | help?: true}
      assert CommandLine.parse_args!(args) == expected
    end

    test "falls back to environment variables when no arguments are given" do
      safe_put_env("INPUT_SCRIPT", @script)
      safe_put_env("INPUT_DEBUG", "true")

      args = []
      expected = %CommandLine.ParsedArgs{debug?: true, help?: false, script: @script}

      assert CommandLine.parse_args!(args) == expected
    end

    test "gives precedence to command-line arguments over environment variables" do
      safe_put_env("INPUT_SCRIPT", "Env script")

      args = ["--script", @script]
      expected = %CommandLine.ParsedArgs{debug?: false, help?: false, script: @script}

      assert CommandLine.parse_args!(args) == expected
    end
  end

  def safe_put_env(varname, value) do
    original_value = System.get_env(varname)
    System.put_env(varname, value)

    on_exit(fn ->
      if original_value,
        do: System.put_env(varname, original_value),
        else: System.delete_env(varname)
    end)
  end
end

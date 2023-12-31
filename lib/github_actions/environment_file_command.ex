defmodule ElixirScript.GitHubActions.EnvironmentFileCommand do
  @moduledoc """
  Handles GitHub Actions Workflow Commands Environment Files.

  This module is designed to interact with GitHub Actions by issuing
  workflow commands to environment files as specified in the GitHub Actions documentation:
  [Workflow Environment File Commands for GitHub Actions](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#environment-files).
  """

  def issue_file_command(command, command_value) do
    file_path = System.get_env("GITHUB_#{command}", "")

    if not File.exists?(file_path) do
      raise "Missing file at path: #{file_path}"
    end

    File.write!(file_path, command_value <> "\n", [:append])
  end

  @doc """
  Prepares a key-value message in a format that uses a unique GitHub Actions-style delimiter

  This function safely prepares a message based on the provided key and value.
  It encodes that message using a specific delimiter format "ghadelimiter_" followed by a unique reference.

  Note: This format is taken from https://github.com/actions/toolkit/blob/main/packages/core/src/file-command.ts#L27
  I can't find this behavior described in GitHub documentation.

  ## Raises:
    - An error if the key or converted value contains the delimiter
      (this can't realistically happen as the delimiter is randomly generated, but better cautious than sorry)
  """
  def prepare_key_value_message(key, command_value) do
    delimiter = "ghadelimiter_" <> to_string(:erlang.ref_to_list(:erlang.make_ref()))

    cond do
      String.contains?(key, delimiter) ->
        raise "Unexpected input: name should not contain the delimiter \"#{delimiter}\""

      String.contains?(command_value, delimiter) ->
        raise "Unexpected input: value should not contain the delimiter \"#{delimiter}\""

      true ->
        "#{key}<<#{delimiter}\n#{command_value}\n#{delimiter}"
    end
  end

  @doc """
  Logs the given `content` to the console. If a `label` is provided, it is
  printed before the content, and the content is indented by two spaces.

  ## Examples

      iex> ElixirScript.GitHubActions.EnvironmentFileCommand.log_content("Hello, world!", "Greeting")
      Greeting:
        Hello, world!

      iex> ElixirScript.GitHubActions.EnvironmentFileCommand.log_content("Hello, world!")
      Hello, world!

  """
  def log_content(content, label \\ nil) do
    indented_content = String.replace(content, "\n", "\n  ")

    case label do
      nil -> IO.puts(indented_content)
      _ -> IO.puts("#{label}:\n  #{indented_content}")
    end
  end

  @doc """
  Logs the contents of the files specified by the "GITHUB_OUTPUT" and "GITHUB_ENV"
  environment variables to the console, each under its own labeled section.

  ## Example

      # Assuming GITHUB_OUTPUT and GITHUB_ENV are set to valid file paths
      # with the contents "output content" and "env content" respectively.
      iex> ElixirScript.GitHubActions.EnvironmentFileCommand.log_output()
      ::group::Set outputs
      GITHUB_OUTPUT:
        output content
      GITHUB_ENV:
        env content
      ::endgroup::
  """
  def log_output do
    IO.puts("::group::Set outputs")

    "GITHUB_OUTPUT"
    |> System.get_env()
    |> File.read!()
    |> log_content("GITHUB_OUTPUT")

    "GITHUB_ENV"
    |> System.get_env()
    |> File.read!()
    |> log_content("GITHUB_ENV")

    IO.puts("::endgroup::")
  end
end

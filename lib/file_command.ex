defmodule ElixirScript.FileCommand do
  alias ElixirScript.CommandUtils

  def issue_file_command(command, message) do
    file_path = System.fetch_env!("GITHUB_#{command}")

    if not File.exists?(file_path) do
      raise "Missing file at path: #{file_path}"
    end

    File.write!(file_path, CommandUtils.to_command_value(message) <> "\n", [:append])
  end

  @doc """
  Prepares a key-value message in a format that uses a unique GitHub Actions-style delimiter

  This function safely prepares a message based on the provided key and value.
  It encodes that message using a specific delimiter format "ghadelimiter_" followed by a unique reference.

  Note: This format is taken from https://github.com/actions/toolkit/blob/main/packages/core/src/file-command.ts#L27
  I don't really understand how this delimiter works, and I can't find it documented.
  But I guess GitHub Actions listens for the "ghadelimiter_" part and then uses that to delimit the message.

  ## Raises:
    - An error if the key or converted value contains the delimiter
      (this can't realistically happen as the delimiter is randomly generated, but better cautious than sorry)
  """
  def prepare_key_value_message(key, value) do
    delimiter = "ghadelimiter_" <> to_string(:erlang.ref_to_list(:erlang.make_ref()))

    converted_value = CommandUtils.to_command_value(value)

    cond do
      String.contains?(key, delimiter) ->
        raise "Unexpected input: name should not contain the delimiter \"#{delimiter}\""

      String.contains?(converted_value, delimiter) ->
        raise "Unexpected input: value should not contain the delimiter \"#{delimiter}\""

      true ->
        "#{key}<<#{delimiter}\n#{converted_value}\n#{delimiter}"
    end
  end
end

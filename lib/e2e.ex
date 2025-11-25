defmodule ElixirScript.E2e.Entry do
  @moduledoc """
  A struct representing the data for an E2E test
  """

  defstruct id: nil, name: nil, script: nil, file_content: nil, expected: nil
end

defmodule ElixirScript.E2e do
  @moduledoc """
  Provides functionality for reading and processing end-to-end (E2E) test data,
  transforming the data into Entry structs that can be consumed in different contexts.
  """
  alias ElixirScript.E2e.Entry

  def read_test_file(file_path \\ "test/e2e_data.exs") do
    {data, _} =
      file_path
      |> Code.eval_file()

    data
    |> Enum.map(&process_entry/1)
  end

  defp process_entry(entry) do
    name = Map.fetch!(entry, :name)
    script = Map.get(entry, :script)
    file_content = Map.get(entry, :file_content)
    expected = Map.get(entry, :expected)

    if !script do
      raise(KeyError, "key :script not found in: #{inspect(entry)}")
    end

    %Entry{
      id: slugify(name),
      name: name,
      script: script,
      file_content: file_content,
      expected: expected
    }
  end

  defp slugify(name),
    do:
      name
      |> String.replace(~r/\s+/, "-")
      |> String.replace(",", "")
      |> String.downcase()
end

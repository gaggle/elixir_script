defmodule ElixirScript.E2e.Entry do
  @moduledoc """
  A struct representing the data for an E2E test
  """

  defstruct id: nil, name: nil, script: nil, file: nil, expected: nil
end

defmodule ElixirScript.E2e do
  alias ElixirScript.E2e.Entry

  def read_test_file(file_path \\ "test/e2e_data.exs") do
    {data, _} = file_path
    |> Code.eval_file()

    data
    |> Enum.map(&process_entry/1)
  end

  defp process_entry(entry) do
    name = Map.fetch!(entry, :name)
    script = Map.get(entry, :script)
    file = Map.get(entry, :file)
    expected = Map.get(entry, :expected)

    if(!script && !file) do
      raise(KeyError, "key :script or :file not found in: #{inspect(entry)}")
    end

    %Entry{
      id: slugify(name),
      name: name,
      script: script,
      file: file,
      expected: expected
    }
  end

  defp slugify(name), do: name
    |> String.replace(~r/\s+/, "-")
    |> String.replace(",", "")
    |> String.downcase()
end

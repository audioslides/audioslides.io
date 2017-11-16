defmodule Platform.FileHelper do
  @moduledoc """
  Simple
  """

  def write_to_file(filename, data) do
    [_, directory, filename] = Regex.run(~r/^(.*\/)([^\/]*)$/, filename)
    File.mkdir_p(directory)
    {:ok, file} = File.open filename, [:write]
    IO.binwrite(file, data)
    File.close(file)
  end

end

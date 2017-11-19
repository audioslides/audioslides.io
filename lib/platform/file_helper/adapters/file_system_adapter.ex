defmodule Platform.FileHelper.FileSystemAdapter do
  @moduledoc """
  Simple
  """

  @behaviour Platform.FileHelper

  def write_to_file(filename, data) do
    [_, directory, _] = Regex.run(~r/^(.*\/)([^\/]*)$/, filename)
    File.mkdir_p(directory)
    {:ok, file} = File.open filename, [:write]
    IO.binwrite(file, data)
    File.close(file)
  end

end

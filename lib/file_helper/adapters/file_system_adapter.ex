defmodule FileHelper.FileSystemAdapter do
  @moduledoc """
  Simple
  """

  @behaviour FileHelper

  def write_to_file(filename, data) do
    [_, directory, _] = Regex.run(~r/^(.*\/)([^\/]*)$/, filename)
    File.mkdir_p(directory)
    {:ok, file} = File.open(filename, [:write])
    IO.binwrite(file, data)
    File.close(file)
  end

  def remove_file(filename) do
    File.rm(filename)
  end

  def remove_folder(directory) do
    File.rm_rf(directory)
  end
end

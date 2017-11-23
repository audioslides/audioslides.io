defmodule Platform.FileHelper.FileSystemTestAdapter do
  @moduledoc """
  Simple
  """

  @behaviour Platform.FileHelper

  def write_to_file(filename, _data) do
    #IO.puts "data written to #{filename}"
  end

end

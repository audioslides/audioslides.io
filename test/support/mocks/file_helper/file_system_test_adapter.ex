defmodule FileHelper.FileSystemTestAdapter do
  @moduledoc """
  Simple
  """

  require Logger

  @behaviour FileHelper

  def write_to_file(filename, _data) do
    Logger.info("#{__MODULE__}: Some data would be written in #{filename}")
  end

  def remove_file(filename) do
    Logger.info("#{__MODULE__}: #{filename} would be deleted")
  end

  def remove_folder(directory) do
    Logger.info("#{__MODULE__}: The directory #{directory} would be deleted")
  end
end

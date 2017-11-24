defmodule Platform.FileHelper.FileSystemTestAdapter do
  @moduledoc """
  Simple
  """

  require Logger

  @behaviour Platform.FileHelper

  def write_to_file(filename, _data) do
    Logger.info "#{__MODULE__}: Some data would be written in #{filename}"
  end

end

defmodule Platform.VideoConverter do
  @moduledoc """
  Context for the general converter
  """
  @adapter Application.get_env(:platform, MODULE, [])[:adapter]

  defdelegate generate_video(opts), to: Platform.VideoConverter.FFMpegAdapter
  defdelegate merge_videos(opts), to: Platform.VideoConverter.FFMpegAdapter

end

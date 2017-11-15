defmodule Platform.VideoConverter do
  @moduledoc """
  Context for the general converter
  """
  @adapter Application.get_env(:platform, MODULE, [])[:adapter]

  defdelegate generate_video(image_filename: image_filename, audio_filename: audio_filename, output_filename: output_filename), to: @adapter
  defdelegate merge_videos(video_filename_list: video_filename_list, output_filename: output_filename), to: @adapter

end

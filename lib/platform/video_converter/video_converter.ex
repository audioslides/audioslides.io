defmodule Platform.VideoConverter do
  @moduledoc """
  Context for the general converter
  """
  @adapter Application.get_env(:adapter, __MODULE__, [])

  def generate_video(image_filename: image_filename, audio_filename: audio_filename, output_filename: output_filename) do
    @adapter.deliver(
      image_filename: image_filename,
      audio_filename: audio_filename,
      output_filename: output_filename
      )
  end
  def merge_videos(video_filename_list: video_filename_list, output_filename: output_filename) do
    @adapter.deliver(
      video_filename_list: video_filename_list,
      output_filename: output_filename
      )
  end

end

defmodule Platform.VideoConverter.TestAdapter do
  @moduledoc """
  A video converter test adapter
  """

  @behaviour Platform.VideoConverter.Adapter

  def generate_video(image_filename: image_filename, audio_filename: audio_filename, output_filename: output_filename) do
    IO.puts "TestAdapter for generate_video "
  end

  def merge_videos(video_filename_list: video_filename_list, output_filename: output_filename) do
    IO.puts "TestAdapter for merge_videos "
  end

end

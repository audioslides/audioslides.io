defmodule Platform.VideoConverter.TestAdapter do
  @moduledoc """
  A video converter test adapter
  """

  @behaviour Platform.VideoConverter

  def generate_video(image_filename: _image_filename, audio_filename: _audio_filename, output_filename: _output_filename) do
    IO.puts "TestAdapter for generate_video "
  end

  def merge_videos(video_filename_list: _video_filename_list, output_filename: _output_filename) do
    IO.puts "TestAdapter for merge_videos "
  end

end

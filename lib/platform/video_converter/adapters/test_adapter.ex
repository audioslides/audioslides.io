defmodule Platform.VideoConverter.TestAdapter do
  @moduledoc """
  A video converter test adapter
  """

  @behaviour Platform.VideoConverter

  def generate_video([image_filename: _image_filename, audio_filename: _audio_filename, output_filename: _output_filename] = opts) do
    Agent.update(__MODULE__, fn {generate_video_list, merge_videos_list} -> {[opts | generate_video_list], merge_videos_list} end)
  end

  def merge_videos([video_filename_list: _video_filename_list, output_filename: _output_filename] = opts) do
    Agent.update(__MODULE__, fn {generate_video_list, merge_videos_list} -> {generate_video_list, [opts | merge_videos_list]} end)
  end

  def start_link do
    Agent.start_link(fn -> {[], []} end, name: __MODULE__)
  end

  def merge_videos_list do
    {_, list} = Agent.get(__MODULE__, &(&1))
    list
  end

  def generate_video_list do
    {list, _} = Agent.get(__MODULE__, &(&1))
    list
  end

  def clear do
    Agent.update(__MODULE__, fn _calls -> {[], []} end)
  end

end

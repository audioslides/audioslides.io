defmodule Platform.VideoConverter.FFMpegAdapter do
  @moduledoc """
  Context for the ffmpeg converter
  """

  alias Platform.Filename
  alias Platform.FileHelper

  @behaviour Platform.VideoConverter

  def generate_video(image_filename: image_filename, audio_filename: audio_filename, output_filename: output_filename) do
    duration = get_audio_duration(audio_filename)
    opts = "-loop 1 -t #{duration} -i #{image_filename} -i #{audio_filename} -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest -y #{output_filename}"
    System.cmd("ffmpeg", String.split(opts, " "))
  end

  def merge_videos(video_filename_list: video_filename_list, output_filename: output_filename) do
    concat_input_filename = Filename.get_filename_for_ffmpeg_concat()
    filecontent = generate_video_filenames_in_ffmpeg_format(video_filename_list)

    FileHelper.write_to_file(concat_input_filename, filecontent)

    opts = "-f concat -safe 0 -i #{concat_input_filename} -c copy -y #{output_filename}"
    System.cmd("ffmpeg", String.split(opts, " "))
  end

  def get_audio_duration(audio_filename) do
    opts = "-i #{audio_filename}"
    {result, _} = System.cmd("ffmpeg", String.split(opts, " "), stderr_to_stdout: true)
    get_audiofile_duration_from_ffmpeg_response(result)
  end

  def get_audiofile_duration_from_ffmpeg_response(ffmpeg_response) do
    # get the duration from the
    duration_regex = ~r/Duration: \d\d:(\d\d:\d\d\.\d\d)/
    [_, duration] = Regex.run(duration_regex, ffmpeg_response)
    duration

  end

  @doc """
  create a input file in ffmpeg concat format

  iex> generate_video_filenames_in_ffmpeg_format(["1", "2"])
  "file '1'
  file '2'
  "

  iex> generate_video_filenames_in_ffmpeg_format(nil)
  ""

  """
  def generate_video_filenames_in_ffmpeg_format(filenames) when is_list(filenames) do
    Enum.map_join(filenames,
      fn(filename) ->
        "file '#{filename}'\n"
      end)
  end
  def generate_video_filenames_in_ffmpeg_format(_), do: ""
end

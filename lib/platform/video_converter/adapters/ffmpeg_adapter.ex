defmodule Platform.VideoConverter.FFMpegAdapter do
  @moduledoc """
  Context for the ffmpeg converter
  """

  alias Platform.Filename

  @behaviour Platform.VideoConverter

  def generate_video(image_filename: image_filename, audio_filename: audio_filename, output_filename: output_filename) do
    duration = get_audio_duration(audio_filename)
    opts = "-loop 1 -t #{duration} -i #{image_filename} -i #{audio_filename} -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest -y #{output_filename}"
    System.cmd("ffmpeg", String.split(opts, " "))
  end

  def merge_videos([video_filename_list: video_filename_list, output_filename: output_filename]) do
    concat_input_filename = Filename.get_filename_for_ffmpeg_concat()
    save_video_filenames(video_filename_list, concat_input_filename)
    opts = "-f concat -safe 0 -i #{concat_input_filename} -c copy -y #{output_filename}"
    System.cmd("ffmpeg", String.split(opts, " "))
  end

  def get_audio_duration(audio_filename) do
    opts = "-i #{audio_filename}"
    result = System.cmd("ffmpeg", String.split(opts, " "), stderr_to_stdout: true)
    get_audiofile_duration_from_ffmpeg_response(elem(result, 0))
  end

  def get_audiofile_duration_from_ffmpeg_response(ffmpeg_response) do
    # get the duration from the
    duration_regex = ~r/Duration: \d\d:(\d\d:\d\d\.\d\d)/
    [_, duration] = Regex.run(duration_regex, ffmpeg_response)
    duration

  end

  @doc """
  create a input file in ffmpeg concat format

  """
  def save_video_filenames(filenames, output_file) do
    File.rm(output_file)
    {:ok, file} = File.open(output_file, [:append])

    Enum.each(filenames,
      fn(filename) ->
        IO.binwrite(file, "file '#{filename}'\n")
      end)

    File.close(file)
  end
end

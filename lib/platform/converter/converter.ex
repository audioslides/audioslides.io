defmodule Platform.Converter do
  @moduledoc """
  Context for the ffmpeg converter
  """

  alias Platform.Filename

  @behaviour Platform.ConverterBehavior

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

  @doc """
  use audio_filename to get the duration of this file

  # iex> get_audio_duration("test/support/fixtures/slide.mp3")
  # "00:08.59"

  """
  def get_audio_duration(audio_filename) do
    opts = "-i #{audio_filename}"
    result = System.cmd("ffmpeg", String.split(opts, " "), stderr_to_stdout: true)
    get_audiofile_duration_from_ffmpeg_response(elem(result, 0))
  end

  @doc """

  Read duration from a response string of ffmpeg

  iex> example_string = "ffmpeg version 3.0.2 Copyright (c) 2000-2016 the FFmpeg developers\\nbuilt with Apple LLVM version 7.3.0 (clang-703.0.29)\\n  configuration: --prefix=/usr/local/Cellar/ffmpeg/3.0.2 --enable-shared --enable-pthreads --enable-gpl --enable-version3 --enable-hardcoded-tables --enable-avresample --cc=clang --host-cflags= --host-ldflags=--enable-opencl --enable-libx264 --enable-libmp3lame --enable-libxvid --enable-vda\\n  libavutil      55. 17.103 / 55. 17.103\\n  libavcodec     57. 24.102 / 57. 24.102\\n  libavformat    57. 25.100 / 57. 25.100\\n  libavdevice    57.  0.101 / 57.  0.101\\n  libavfilter     6. 31.100 /  6. 31.100\\n  libavresample   3.  0.  0 /  3.  0.  0\\n  libswscale      4.  0.100 /  4.  0.100\\n  libswresample   2.  0.101 /  2.  0.101\\n  libpostproc    54.  0.100 / 54.  0.100\\n[mp3 @ 0x7fe8b3800a00] Skipping 0 bytes of junk at 45.\\n[mp3 @ 0x7fe8b3800a00] Estimating duration from bitrate, this may be inaccurate\\nInput #0, mp3, from 'priv/static/content/4/1.mp3':\\n  Metadata:\\n    encoder         : Lavf57.71.100\\n  Duration: 00:00:17.21, start: 0.000000, bitrate: 32 kb/s\\n    Stream #0:0: Audio: mp3, 8000 Hz, mono, s16p, 32 kb/s\\nAt least one outputfile must be specified\\n"
  iex> get_audiofile_duration_from_ffmpeg_response(example_string)
  "00:17.21"

  """
  def get_audiofile_duration_from_ffmpeg_response(ffmpeg_response) do
    # get the duration from the
    duration_regex = ~r/Duration: \d\d:(\d\d:\d\d\.\d\d)/
    [_, duration] = Regex.run(duration_regex, ffmpeg_response)
    duration

  end

  @doc """
  create a input file in ffmpeg concat format

  """
  defp save_video_filenames(filenames, output_file) do
    File.rm(output_file)
    {:ok, file} = File.open(output_file, [:append])

    Enum.each(filenames,
      fn(filename) ->
        IO.binwrite(file, "file '#{filename}'\n")
      end)

    File.close(file)
  end
end

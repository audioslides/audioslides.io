defmodule Platform.Speech.Mock.System do
  @moduledoc """
  The Speech Mock context
  """

  def cmd("ffmpeg", ["-i", "1.mp3"], stderr_to_stdout: true) do
  {"""
  ffmpeg version 3.0.2 Copyright (c) 2000-2016 the FFmpeg developers
  built with Apple LLVM version 7.3.0 (clang-703.0.29)
  configuration: --prefix=/usr/local/Cellar/ffmpeg/3.0.2 --enable-shared --enable-pthreads --enable-gpl --enable-version3 --enable-hardcoded-tables --enable-avresample --cc=clang --host-cflags= --host-ldflags= --enable-opencl --enable-libx264 --enable-libmp3lame --enable-libxvid --enable-vda
  libavutil      55. 17.103 / 55. 17.103
  libavcodec     57. 24.102 / 57. 24.102
  libavformat    57. 25.100 / 57. 25.100
  libavdevice    57.  0.101 / 57.  0.101
  libavfilter     6. 31.100 /  6. 31.100
  libavresample   3.  0.  0 /  3.  0.  0
  libswscale      4.  0.100 /  4.  0.100
  libswresample   2.  0.101 /  2.  0.101
  libpostproc    54.  0.100 / 54.  0.100
[mp3 @ 0x7fa15e000a00] Skipping 0 bytes of junk at 45.
[mp3 @ 0x7fa15e000a00] Estimating duration from bitrate, this may be inaccurate
Input #0, mp3, from 'slide.mp3':
  Metadata:
    encoder         : Lavf57.71.100
  Duration: 00:00:09.59, start: 0.000000, bitrate: 48 kb/s
    Stream #0:0: Audio: mp3, 22050 Hz, mono, s16p, 48 kb/s
At least one output file must be specified

  """, 1}
  end
  def cmd(_command, _args, _opts), do: ""

  def cmd("ffmpeg", ["-loop", "1", "-t", "00:09.59", "-i", _image_filename, "-i", _audio_filename, "-c:v", "libx264", "-tune", "stillimage", "-c:a", "aac", "-b:a", "192k", "-pix_fmt", "yuv420p", "-shortest", "-y", output_filename]) do
    {"""
    ffmpeg version 3.0.2 Copyright (c) 2000-2016 the FFmpeg developers
    Output #0, mp4, to '#{output_filename}':
    [libx264 @ 0x7ff3c8012000] ref P L0: 76.7% 23.3%
    [libx264 @ 0x7ff3c8012000] kb/s:33.66
    [aac @ 0x7ff3c8013200] Qavg: 55622.996
    """, 1}
  end
  def cmd(command, args), do: cmd(command, args, [])

end

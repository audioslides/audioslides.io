defmodule Platform.VideoConverter.FFMpegAdapterIntegrationTest do
  use ExUnit.Case
  import Platform.VideoConverter.FFMpegAdapter

  @moduletag integration: true

  test "generate_video" do
    result = generate_video(image_filename: "1.png", audio_filename: "1.mp3", output_filename: "out.mp4")

    assert elem(result, 0) =~ "Output #0, mp4, to 'out.mp4"
  end

  test "merge_videos" do
    result = merge_videos(video_filename_list: ["1.mp4", "2.mp4"], output_filename: "out.mp4")
    assert elem(result, 0) =~ "merged"
  end

  test "get_audio_duration" do
    result = get_audio_duration("1.mp3")
    assert result == "00:09.59"
  end

  test "get_audiofile_duration_from_ffmpeg_response" do
    example_string =
      "ffmpeg version 3.0.2 Copyright (c) 2000-2016 the FFmpeg developers\\nbuilt with Apple LLVM version 7.3.0 (clang-703.0.29)\\n  configuration: --prefix=/usr/local/Cellar/ffmpeg/3.0.2 --enable-shared --enable-pthreads --enable-gpl --enable-version3 --enable-hardcoded-tables --enable-avresample --cc=clang --host-cflags= --host-ldflags=--enable-opencl --enable-libx264 --enable-libmp3lame --enable-libxvid --enable-vda\\n  libavutil      55. 17.103 / 55. 17.103\\n  libavcodec     57. 24.102 / 57. 24.102\\n  libavformat    57. 25.100 / 57. 25.100\\n  libavdevice    57.  0.101 / 57.  0.101\\n  libavfilter     6. 31.100 /  6. 31.100\\n  libavresample   3.  0.  0 /  3.  0.  0\\n  libswscale      4.  0.100 /  4.  0.100\\n  libswresample   2.  0.101 /  2.  0.101\\n  libpostproc    54.  0.100 / 54.  0.100\\n[mp3 @ 0x7fe8b3800a00] Skipping 0 bytes of junk at 45.\\n[mp3 @ 0x7fe8b3800a00] Estimating duration from bitrate, this may be inaccurate\\nInput #0, mp3, from 'priv/static/content/4/1.mp3':\\n  Metadata:\\n    encoder         : Lavf57.71.100\\n  Duration: 00:00:17.21, start: 0.000000, bitrate: 32 kb/s\\n    Stream #0:0: Audio: mp3, 8000 Hz, mono, s16p, 32 kb/s\\nAt least one outputfile must be specified\\n"

    result = get_audiofile_duration_from_ffmpeg_response(example_string)
    assert result == "00:17.21"
  end
end

defmodule VideoConverter.FFMpegAdapterTest do
  @moduledoc """
  This test mocks all System.cmd and File Write calls.
  There is also an integration test for this calls.
  """
  use ExUnit.Case
  import VideoConverter.FFMpegAdapter
  import Mock

  doctest VideoConverter.FFMpegAdapter

  test "generate_video" do
    with_mocks [
      {System, [], [
        cmd: fn _, _, stderr_to_stdout: true ->
          {"Duration: 00:00:09.59, start: 0.000000, bitrate: 48 kb/s", 1}
        end,
        cmd: fn _, _ -> {"FFMPEG OUTPUT", 1} end
      ]}
    ] do
      generate_video(image_filename: "1.png", audio_filename: "1.mp3", output_filename: "out.mp4")

      assert called(
               System.cmd("ffmpeg", [
                 "-loop",
                 "1",
                 "-t",
                 "00:09.59",
                 "-i",
                 "1.png",
                 "-i",
                 "1.mp3",
                 "-c:v",
                 "libx264",
                 "-tune",
                 "stillimage",
                 "-c:a",
                 "aac",
                 "-b:a",
                 "192k",
                 "-pix_fmt",
                 "yuv420p",
                 "-shortest",
                 "-y",
                 "out.mp4"
               ])
             )
    end
  end

  test "merge_videos" do
    with_mocks [
      {System, [], [
        cmd: fn _, _, _ -> :ok end,
        cmd: fn _, _ -> :ok end
      ]},
      {File, [], [
        rm: fn _ -> true end,
        close: fn _ -> true end,
        mkdir_p: fn _ -> true end,
        open: fn _out, _opts -> {:ok, nil} end
      ]}
    ] do
      merge_videos(
        video_filename_list: ["priv/static/1.mp4", "priv/static/2.mp4"],
        output_filename: "priv/static/out.mp4"
      )

      assert called(
               System.cmd("ffmpeg", [
                 "-f",
                 "concat",
                 "-safe",
                 "0",
                 "-i",
                 :_,
                 "-c",
                 "copy",
                 "-y",
                 "priv/static/out.mp4"
               ])
             )
    end
  end

  test "get_duration" do
    with_mock System,
      cmd: fn _, _, stderr_to_stdout: true ->
        {"Duration: 00:00:09.59, start: 0.000000, bitrate: 48 kb/s", 1}
      end do
      result = get_duration("1.mp3")
      assert result == "00:09.59"
    end
  end

  test "get_duration_from_ffmpeg_response" do
    example_string =
      "ffmpeg version 3.0.2 Copyright (c) 2000-2016 the FFmpeg developers\\nbuilt with Apple LLVM version 7.3.0 (clang-703.0.29)\\n  configuration: --prefix=/usr/local/Cellar/ffmpeg/3.0.2 --enable-shared --enable-pthreads --enable-gpl --enable-version3 --enable-hardcoded-tables --enable-avresample --cc=clang --host-cflags= --host-ldflags=--enable-opencl --enable-libx264 --enable-libmp3lame --enable-libxvid --enable-vda\\n  libavutil      55. 17.103 / 55. 17.103\\n  libavcodec     57. 24.102 / 57. 24.102\\n  libavformat    57. 25.100 / 57. 25.100\\n  libavdevice    57.  0.101 / 57.  0.101\\n  libavfilter     6. 31.100 /  6. 31.100\\n  libavresample   3.  0.  0 /  3.  0.  0\\n  libswscale      4.  0.100 /  4.  0.100\\n  libswresample   2.  0.101 /  2.  0.101\\n  libpostproc    54.  0.100 / 54.  0.100\\n[mp3 @ 0x7fe8b3800a00] Skipping 0 bytes of junk at 45.\\n[mp3 @ 0x7fe8b3800a00] Estimating duration from bitrate, this may be inaccurate\\nInput #0, mp3, from 'priv/static/content/4/1.mp3':\\n  Metadata:\\n    encoder         : Lavf57.71.100\\n  Duration: 00:00:17.21, start: 0.000000, bitrate: 32 kb/s\\n    Stream #0:0: Audio: mp3, 8000 Hz, mono, s16p, 32 kb/s\\nAt least one outputfile must be specified\\n"

    result = get_duration_from_ffmpeg_response(example_string)
    assert result == "00:17.21"
  end
end

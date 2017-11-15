defmodule Platform.VideoConverter.Adapter do
  @moduledoc """
  Behavior for a video converter
  """

  @doc """
  Generate a video from an image and an audio file

  The return value is the filename of the generated file as {:ok, filename}
  If an error occurs the an {:error, reason will be returned}
  """
  @callback generate_video([image_filename: String.t, audio_filename: String.t, output_filename: String.t]) :: {:ok, String.t} | {:error, String.t}

  @doc """
  Cocats a list of video files to one single video file

  The return value is the filename of the generated file as {:ok, filename}
  If an error occurs the an {:error, reason will be returned}
  """
  @callback merge_videos([video_filename_list: list(String.t), output_filename: String.t]) :: {:ok, String.t} | {:error, String.t}

end

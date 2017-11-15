defmodule Platform.VideoConverter do
  @moduledoc """
  Context for the general converter
  """
  @adapter Application.get_env(:platform, __MODULE__, [])[:adapter]

  defdelegate generate_video(opts), to: @adapter
  defdelegate merge_videos(opts), to: @adapter

end

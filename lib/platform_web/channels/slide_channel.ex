defmodule PlatformWeb.SlideChannel do
  @moduledoc """
  The speechChannel for socket communitcation in the context of a room
  """
  use PlatformWeb, :channel

  alias Platform.Speech
  alias Filename
  alias FileHelper

  @content_dir Application.get_env(:platform, :content_dir)

  def join("slide", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("speech", payload, socket) do

    uuid = UUID.uuid1()
    audio_filename = "#{@content_dir}#{uuid}.mp3"
    speech_binary = Speech.run(payload)

    FileHelper.write_to_file(audio_filename, speech_binary)

    preview_url = "/content/#{uuid}.mp3"

    broadcast! socket, "speech", %{"preview_url"=> preview_url}
    {:noreply, socket}
  end
end

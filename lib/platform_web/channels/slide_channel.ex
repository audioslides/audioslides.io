defmodule PlatformWeb.SlideChannel do
  @moduledoc """
  The speechChannel for socket communitcation in the context of a room
  """
  use PlatformWeb, :channel

  alias Platform.Speech

  def join("slide", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("speech", payload, socket) do
    preview_url = Speech.get_speech_url(payload)

    broadcast! socket, "speech", %{"preview_url"=> preview_url}
    {:noreply, socket}
  end
end

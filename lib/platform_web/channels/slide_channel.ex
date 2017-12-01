defmodule PlatformWeb.SlideChannel do
  @moduledoc """
  The speechChannel for socket communitcation in the context of a room
  """
  use PlatformWeb, :channel

  alias Platform.Speech

  def join("slide", _payload, socket) do
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("speech", payload, socket) do
    preview_url = Speech.get_speech_url(payload)
    {:reply, {:ok, %{"preview_url"=> preview_url}}, socket}
  end
end

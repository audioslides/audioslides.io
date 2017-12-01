defmodule PlatformWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "slide", PlatformWeb.SlideChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end

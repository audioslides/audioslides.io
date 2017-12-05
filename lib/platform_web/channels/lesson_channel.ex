defmodule PlatformWeb.LessonChannel do
  @moduledoc """
  The lesson channel for socket communication in the context of a room
  """
  use PlatformWeb, :channel

  def join("lesson:" <> lesson_id, _payload, socket) do
    # socket_with_lesson_id =
    #   socket
    #   |> assign(:lesson_id, lesson_id)

    {:ok, socket}
  end
end

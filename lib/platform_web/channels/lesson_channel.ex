defmodule PlatformWeb.LessonChannel do
  @moduledoc """
  The lesson channel for socket communication in the context of a room
  """
  use PlatformWeb, :channel

  def join("lesson:" <> lesson_id, _payload, socket) do
    socket_with_lesson_id =
      socket
      |> assign(:lesson_id, lesson_id)

    {:ok, socket_with_lesson_id}
  end

  def broadcast_processing_to_socket(lesson) do
    html = Phoenix.View.render_to_string(PlatformWeb.LessonView, "_processing.html", lesson: lesson, conn: PlatformWeb.Endpoint)
    PlatformWeb.Endpoint.broadcast!("lesson:#{lesson.id}", "new-processing-state", %{lesson_html: html})
  end
end

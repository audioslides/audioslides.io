defmodule PlatformWeb.PageController do
  use PlatformWeb, :controller

  alias PlatformWeb.AccessHelper

  def index(conn, _params) do
    lessons = AccessHelper.list_lessons(conn)

    if lesson = List.first(lessons) do
      html =
        Phoenix.View.render_to_string(PlatformWeb.LessonView, "_lesson.html", lesson: lesson, conn: conn)
      PlatformWeb.Endpoint.broadcast!("lesson:#{lesson.id}", "new-processing-state", %{lesson_html: html})
    end

    render(conn, "index.html", lessons: lessons)
  end
end

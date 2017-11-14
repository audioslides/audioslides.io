defmodule PlatformWeb.SlideController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Video

  def show(conn, %{"lesson_id" => lesson_id, "id" => id}) do
    lesson = Core.get_lesson_with_slides!(lesson_id)
    slide = Core.get_slide!(lesson, id)

    render conn, "show.html", lesson: lesson, slide: slide
  end

  def generate_video(conn, %{"lesson_id" => lesson_id, "id" => id}) do
    lesson = Core.get_lesson!(lesson_id)
    slide = Core.get_slide!(lesson, id)

    Video.generate_video_for_slide(lesson, slide)

    conn
    |> put_flash(:info, "Thumb downloaded successfully.")
    |> redirect(to: lesson_slide_path(conn, :show, lesson, id))
  end
end

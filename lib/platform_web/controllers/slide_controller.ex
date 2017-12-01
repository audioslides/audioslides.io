defmodule PlatformWeb.SlideController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Video

  def show(conn, %{"lesson_id" => lesson_id, "id" => slide_id}) do
    lesson =
      lesson_id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    slide =
      slide_id
      |> Core.get_slide!()
      |> authorize_action!(conn)

    render(conn, "show.html", lesson: lesson, slide: slide)
  end

  def edit(conn, %{"lesson_id" => lesson_id, "id" => slide_id}) do
    lesson =
      lesson_id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    slide =
      slide_id
      |> Core.get_slide!()
      |> authorize_action!(conn)

    changeset = Core.change_slide(lesson, slide)

    render(conn, "edit.html", lesson: lesson, slide: slide, changeset: changeset)
  end

  def generate_video(conn, %{"lesson_id" => lesson_id, "id" => slide_id}) do
    lesson =
      lesson_id
      |> Core.get_lesson!()
      |> authorize_action!(conn)

    slide =
      slide_id
      |> Core.get_slide!()
      |> authorize_action!(conn)

    Video.generate_video_for_slide(lesson, slide)

    conn
    |> put_flash(:info, "Thumb downloaded successfully.")
    |> redirect(to: lesson_slide_path(conn, :show, lesson, slide_id))
  end

end

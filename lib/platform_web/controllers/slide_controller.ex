defmodule PlatformWeb.SlideController do
  use PlatformWeb, :controller

  alias Platform.GoogleSlides
  alias Platform.Core
  alias Platform.Video

  def show(conn, %{"presentation_id" => presentation_id, "id" => id}) do
    presentation = Core.get_presentation_with_slides!(presentation_id)
    slide = Core.get_slide!(presentation, id)

    render conn, "show.html", presentation: presentation, slide: slide
  end

  def generate_video(conn, %{"presentation_id" => presentation_id, "id" => id}) do
    presentation = Core.get_presentation!(presentation_id)
    slide = Core.get_slide!(presentation, id)

    Video.generate_video_for_slide(presentation, slide)

    conn
    |> put_flash(:info, "Thumb downloaded successfully.")
    |> redirect(to: presentation_slide_path(conn, :show, presentation, id))
  end
end

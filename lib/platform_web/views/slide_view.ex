defmodule PlatformWeb.SlideView do
  use PlatformWeb, :view

  def page("show.html", conn),
    do: %{
      parent: PlatformWeb.LessonView.page("show.html", conn),
      path: lesson_slide_path(conn, :show, conn.assigns.lesson, conn.assigns.slide),
      title: "#{conn.assigns.slide.name} (##{conn.assigns.slide.position + 1} of #{length(conn.assigns.lesson.slides)})"
    }

  def page("edit.html", conn),
    do: %{
      parent: page("show.html", conn),
      title: "Edit slide"
    }

  def google_slides_url(%{google_presentation_id: google_presentation_id}, %{google_object_id: google_object_id}) do
    "https://docs.google.com/presentation/d/#{google_presentation_id}/edit#slide=id.#{google_object_id}"
  end
end

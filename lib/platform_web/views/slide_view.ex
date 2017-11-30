defmodule PlatformWeb.SlideView do
  use PlatformWeb, :view

  def page("show.html", conn),
    do: %{
      parent: PlatformWeb.LessonView.page("show.html", conn),
      title:
        "#{conn.assigns.slide.name} (##{conn.assigns.slide.position + 1} of #{
          length(conn.assigns.lesson.slides)
        })"
    }
end

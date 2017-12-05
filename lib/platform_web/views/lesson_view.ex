defmodule PlatformWeb.LessonView do
  use PlatformWeb, :view
  import PlatformWeb.ViewHelper

  def page("index.html", conn),
    do: %{
      title: "Lessons",
      path: lesson_path(conn, :index)
    }

  def page("manage.html", conn),
    do: %{
      parent: page("index.html", conn),
      title: "Manage Video Generation of #{conn.assigns.lesson.name}"
    }

  def page("new.html", conn),
    do: %{
      parent: page("index.html", conn),
      title: "New lesson"
    }

  def page("show.html", conn),
    do: %{
      parent: page("index.html", conn),
      title: "#{conn.assigns.lesson.name}",
      path: lesson_path(conn, :show, conn.assigns.lesson)
    }

  def page("edit.html", conn),
    do: %{
      parent: page("index.html", conn),
      title: "Edit lesson"
    }

  def state_view(lesson) do
    state = Platform.VideoProcessingState.get_state_for_lesson_video(lesson)
    case state do
      _ -> state
    end
  end
end

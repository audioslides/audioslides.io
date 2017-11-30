defmodule PlatformWeb.CourseLessonView do
  use PlatformWeb, :view

  def page("new.html", _conn),
    do: %{
      # parent: page("index.html", conn),
      title: "New course lesson"
    }

  def page("edit.html", _conn),
    do: %{
      # parent: page("index.html", conn),
      title: "Edit course lesson"
    }
end

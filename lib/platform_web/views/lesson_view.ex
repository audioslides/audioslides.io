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
      title: "123#{conn.assigns.lesson.name}",
      path: lesson_path(conn, :show, conn.assigns.lesson),
      no_container: true,
      no_header: true
    }

  def page("edit.html", conn),
    do: %{
      parent: page("index.html", conn),
      title: "Edit lesson"
    }

  def progressbar(number) when is_integer(number) do
    content_tag(:div, class: "progress") do
      content_tag(:div, class: "progress-bar bg-#{completeness_class_suffix(number)}", role: "progressbar", style: "width: #{number}%") do
        "#{number}%"
      end
    end
  end

  def progress_badge(number) when is_integer(number) do
    content_tag(:span, class: "badge badge-#{completeness_class_suffix(number)}") do
      "#{number}%"
    end
  end

  @doc """
  iex> completeness_class_suffix(29)
  "danger"

  iex> completeness_class_suffix(50)
  "warning"

  iex> completeness_class_suffix(70)
  "success"
  """
  def completeness_class_suffix(number) do
    cond do
      number < 30 -> "danger"
      number < 70 -> "warning"
      number >= 70 -> "success"
    end
  end
end

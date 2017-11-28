defmodule PlatformWeb.PageController do
  use PlatformWeb, :controller

  alias Platform.Core

  def index(conn, _params) do
    lessons =
      if can?(conn, :show, User) do
        Core.list_lessons()
      else
        Core.list_visible_lessons()
      end

    render(conn, "index.html", lessons: lessons)
  end
end

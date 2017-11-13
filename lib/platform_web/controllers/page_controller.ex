defmodule PlatformWeb.PageController do
  use PlatformWeb, :controller

  alias Platform.Core

  def index(conn, _params) do
    lessons = Core.list_lessons()

    render(conn, "index.html", lessons: lessons)
  end
end

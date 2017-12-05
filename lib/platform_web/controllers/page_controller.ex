defmodule PlatformWeb.PageController do
  use PlatformWeb, :controller

  alias PlatformWeb.AccessHelper

  def index(conn, _params) do
    lessons = AccessHelper.list_lessons(conn)

    render(conn, "index.html", lessons: lessons)
  end
end

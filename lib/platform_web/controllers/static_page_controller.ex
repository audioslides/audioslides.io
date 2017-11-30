defmodule PlatformWeb.StaticPageController do
  use PlatformWeb, :controller

  def imprint(conn, _params) do
    render(conn, "imprint.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end

defmodule PlatformWeb.StaticPageView do
  use PlatformWeb, :view

  def page("imprint.html", _conn), do: %{
    title: "Impressum"
  }
  def page("privacy.html", _conn), do: %{
    title: "Datenschutz"
  }
end

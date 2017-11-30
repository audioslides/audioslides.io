defmodule PlatformWeb.PageView do
  use PlatformWeb, :view

  def page("index.html", _conn),
    do: %{
      title: "Homepage"
    }
end

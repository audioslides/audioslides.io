defmodule PlatformWeb.LayoutView do
  use PlatformWeb, :view

  def page(conn) do
    apply(view_module(conn), :page, [conn.private.phoenix_template, conn])
    # rescue
    #   UndefinedFunctionError -> throw("No page(\"#{conn.private.phoenix_template}\", conn) function in '#{view_module(conn)}' defined")
  end
end

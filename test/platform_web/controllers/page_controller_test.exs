defmodule PlatformWeb.PageControllerTest do
  use PlatformWeb.ConnCase

  describe "#index" do
    test "shows the homepage", %{conn: conn} do
      conn = get conn, page_path(conn, :index)
      assert html_response(conn, 200) =~ ~s(<main role="main">)
    end
  end
end

defmodule PlatformWeb.StaticPageControllerTest do
  use PlatformWeb.ConnCase

  describe "#imprint" do
    test "renders the imprint page", %{conn: conn} do
      conn = get conn, static_page_path(conn, :imprint)
      assert html_response(conn, 200) =~ "Impressum"
    end
  end

  describe "#privacy" do
    test "renders the privacy page", %{conn: conn} do
      conn = get conn, static_page_path(conn, :privacy)
      assert html_response(conn, 200) =~ "Datenschutz"
    end
  end

end

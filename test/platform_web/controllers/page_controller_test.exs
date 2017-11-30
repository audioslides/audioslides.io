defmodule PlatformWeb.PageControllerTest do
  use PlatformWeb.ConnCase

  describe "#index" do
    test "shows the homepage", %{conn: conn} do
      conn = get(conn, page_path(conn, :index))
      assert html_response(conn, 200) =~ ~s(<main role="main">)
    end

    test "show only visible lessons if no admin", %{conn: conn} do
      Factory.insert(:lesson, visible: true, name: "A TEST LESSON")
      Factory.insert(:lesson, visible: false, name: "ANOTHER TEST LESSON")

      user = Factory.insert(:user, admin: false)
      conn = %{conn | assigns: %{current_user: user}}
      conn = get(conn, page_path(conn, :index))

      assert html_response(conn, 200) =~ "A TEST LESSON"
      refute html_response(conn, 200) =~ "ANOTHER TEST LESSON"
    end

    test "show all lessons if admin", %{conn: conn} do
      Factory.insert(:lesson, visible: true, name: "A TEST LESSON")
      Factory.insert(:lesson, visible: false, name: "ANOTHER TEST LESSON")

      user = Factory.insert(:user, admin: true)
      conn = %{conn | assigns: %{current_user: user}}
      conn = get(conn, page_path(conn, :index))

      assert html_response(conn, 200) =~ "A TEST LESSON"
      assert html_response(conn, 200) =~ "ANOTHER TEST LESSON"
    end
  end
end

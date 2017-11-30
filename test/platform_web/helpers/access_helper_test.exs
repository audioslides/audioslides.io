defmodule PlatformWeb.AccessHelperTest do
  use PlatformWeb.ConnCase

  import PlatformWeb.AccessHelper

  describe "list_lessons/1" do
    test "should allow admin to view all lessons", %{conn: conn} do
      Factory.insert(:lesson, visible: true, name: "A TEST LESSON")
      Factory.insert(:lesson, visible: false, name: "ANOTHER TEST LESSON")

      user = Factory.insert(:user, admin: true)
      conn = %{conn | assigns: %{current_user: user}}
      conn = get(conn, page_path(conn, :index))

      lessons = list_lessons(conn)

      assert length(lessons) == 2
    end

    test "should show users only visible lessons", %{conn: conn} do
      Factory.insert(:lesson, visible: true, name: "A TEST LESSON")
      Factory.insert(:lesson, visible: false, name: "ANOTHER TEST LESSON")

      user = Factory.insert(:user, admin: false)
      conn = %{conn | assigns: %{current_user: user}}
      conn = get(conn, page_path(conn, :index))

      lessons = list_lessons(conn)

      assert length(lessons) == 1
    end
  end
end

defmodule PlatformWeb.CourseControllerTest do
  use PlatformWeb.ConnCase

  @create_attrs %{name: "A course"}
  @update_attrs %{name: "An awesome course"}
  @invalid_attrs %{name: nil}

  setup :set_current_user_as_admin

  describe "#index" do
    test "lists all courses", %{conn: conn} do
      conn = get(conn, course_path(conn, :index))
      assert html_response(conn, 200) =~ "Courses"
    end
  end

  describe "#new" do
    test "renders form", %{conn: conn} do
      conn = get(conn, course_path(conn, :new))
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "#create" do
    test "redirects to show when data is valid", %{conn: orig_conn} do
      conn = post(orig_conn, course_path(orig_conn, :create), course: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == course_path(conn, :show, id)

      conn = get(orig_conn, course_path(orig_conn, :show, id))
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, course_path(conn, :create), course: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Course"
    end
  end

  describe "#edit" do
    setup [:create_course]

    test "renders form for editing chosen course", %{conn: conn, course: course} do
      conn = get(conn, course_path(conn, :edit, course))
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "#update" do
    setup [:create_course]

    test "redirects when data is valid", %{conn: orig_conn, course: course} do
      conn = put(orig_conn, course_path(orig_conn, :update, course), course: @update_attrs)
      assert redirected_to(conn) == course_path(conn, :show, course)

      conn = get(orig_conn, course_path(orig_conn, :show, course))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = put(conn, course_path(conn, :update, course), course: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Course"
    end
  end

  describe "#delete" do
    setup [:create_course]

    test "deletes chosen course", %{conn: orig_conn, course: course} do
      conn = delete(orig_conn, course_path(orig_conn, :delete, course))
      assert redirected_to(conn) == course_path(conn, :index)

      assert_error_sent(404, fn ->
        get(orig_conn, course_path(orig_conn, :show, course))
      end)
    end
  end

  defp create_course(_) do
    course = Factory.insert(:course)
    {:ok, course: course}
  end

  defp set_current_user_as_admin(%{conn: conn}) do
    user = Factory.insert(:user, admin: true)
    conn = %{conn | assigns: %{current_user: user}}
    {:ok, conn: conn}
  end

end

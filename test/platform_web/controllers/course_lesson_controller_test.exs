defmodule PlatformWeb.CourseLessonControllerTest do
  use PlatformWeb.ConnCase

#   @create_attrs %{active: true, lesson_id: "some lesson_id", symbol: "some symbol"}
#   @update_attrs %{active: false, lesson_id: "some updated lesson_id", symbol: "some updated symbol"}
  @invalid_attrs %{lesson_id: nil}

  # setup :login_as_admin
  setup :create_course

  describe "#new" do
    test "renders form", %{conn: conn, course: course} do
      conn = get conn, course_course_lesson_path(conn, :new, course)
      assert html_response(conn, 200) =~ "New course lesson"
    end
  end

  describe "#create" do
#     test "redirects to show when data is valid", %{conn: conn, course: course} do
#       conn = post conn, course_course_lesson_path(conn, :create), course_lesson: @create_attrs

#       assert %{id: id} = redirected_params(conn)
#       assert redirected_to(conn) == course_course_lesson_path(conn, :show, id)

#       conn = get conn, course_course_lesson_path(conn, :show, id)
#       assert html_response(conn, 200) =~ "Show Course lesson"
#     end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = post conn, course_course_lesson_path(conn, :create, course), course_lesson: @invalid_attrs
      assert html_response(conn, 200) =~ "New course lesson"
    end
  end

  describe "#edit" do
    setup :create_course_lesson

    test "renders form for editing chosen course_lesson", %{conn: conn, course: course, course_lesson: course_lesson} do
      conn = get conn, course_course_lesson_path(conn, :edit, course, course_lesson)
      assert html_response(conn, 200) =~ "Edit course lesson"
    end
  end

#   describe "#update" do
#     setup :create_course_lesson

#     test "redirects when data is valid", %{conn: conn, course: course, course_lesson: course_lesson} do
#       conn = put conn, course_course_lesson_path(conn, :update, course_lesson), course_lesson: @update_attrs
#       assert redirected_to(conn) == course_course_lesson_path(conn, :show, course_lesson)

#       conn = get conn, course_course_lesson_path(conn, :show, course_lesson)
#       assert html_response(conn, 200) =~ "some updated lesson_id"
#     end

#     test "renders errors when data is invalid", %{conn: conn, course_lesson: course_lesson} do
#       conn = put conn, course_course_lesson_path(conn, :update, course_lesson), course_lesson: @invalid_attrs
#       assert html_response(conn, 200) =~ "Edit Course lesson"
#     end
#   end

  describe "#delete" do
    setup :create_course_lesson

    test "deletes chosen course_lesson", %{conn: orig_conn, course: course, course_lesson: course_lesson} do
      conn = delete orig_conn, course_course_lesson_path(orig_conn, :delete, course, course_lesson)
      assert redirected_to(conn) == course_path(conn, :show, course)

      conn = get orig_conn, course_path(orig_conn, :show, course)
      refute html_response(conn, 200) =~ course_lesson.lesson.name
    end
  end

  # Private functions
  defp create_course(_) do
    course = Factory.insert(:course)
    {:ok, course: course}
  end

  defp create_course_lesson(%{course: course}) do
    course_lesson = Factory.insert(:course_lesson, course: course)
    {:ok, course_lesson: course_lesson}
  end
end

defmodule PlatformWeb.LessonControllerTest do
  use PlatformWeb.ConnCase

  @create_attrs %{google_presentation_id: "some google_presentation_id", name: "some name", voice_gender: "male", voice_language: "de-DE"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{google_presentation_id: nil, name: nil, voice_gender: nil, voice_language: nil}

  describe "#index" do
    test "lists all lessons", %{conn: conn} do
      conn = get conn, lesson_path(conn, :index)
      assert html_response(conn, 200) =~ ~s(<main role="main">)
    end
  end

  describe "#new" do
    test "renders form", %{conn: conn} do
      conn = get conn, lesson_path(conn, :new)
      assert html_response(conn, 200) =~ "New Lesson"
    end
  end

  describe "#create" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, lesson_path(conn, :create), lesson: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == lesson_path(conn, :show, id)

      conn = get conn, lesson_path(conn, :show, id)
      assert html_response(conn, 200) =~ "name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, lesson_path(conn, :create), lesson: @invalid_attrs
      assert html_response(conn, 200) =~ "New Lesson"
    end
  end

  describe "#edit" do
    setup [:create_lesson]

    test "renders form for editing chosen lesson", %{conn: conn, lesson: lesson} do
      conn = get conn, lesson_path(conn, :edit, lesson)
      assert html_response(conn, 200) =~ "Edit Lesson"
    end
  end

  describe "#update" do
    setup [:create_lesson]

    test "redirects when data is valid", %{conn: conn, lesson: lesson} do
      conn = put conn, lesson_path(conn, :update, lesson), lesson: @update_attrs
      assert redirected_to(conn) == lesson_path(conn, :show, lesson)

      conn = get conn, lesson_path(conn, :show, lesson)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, lesson: lesson} do
      conn = put conn, lesson_path(conn, :update, lesson), lesson: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Lesson"
    end
  end

  describe "#delete" do
    setup [:create_lesson]

    test "deletes chosen lesson", %{conn: conn, lesson: lesson} do
      conn = delete conn, lesson_path(conn, :delete, lesson)
      assert redirected_to(conn) == lesson_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, lesson_path(conn, :show, lesson)
      end
    end
  end

  describe "#generate_video" do
    setup :create_lesson

    alias Platform.VideoConverter.TestAdapter

    test "renders form for editing chosen lesson", %{conn: conn, lesson: lesson} do
      conn = post conn, lesson_path(conn, :generate_video, lesson)
      assert redirected_to(conn) == lesson_path(conn, :show, lesson)
      assert length(TestAdapter.merge_videos_list) == 1
    end
  end

  defp create_lesson(_) do
    slide_1 = Factory.insert(:slide)
    slide_2 = Factory.insert(:slide)
    lesson = Factory.insert(:lesson, slides: [slide_1, slide_2])
    {:ok, lesson: lesson}
  end
end

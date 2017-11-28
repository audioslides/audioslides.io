defmodule PlatformWeb.LessonControllerTest do
  use PlatformWeb.ConnCase

  import Mock
  import Mox

  @create_attrs %{google_presentation_id: "some google_presentation_id", name: "some name", voice_gender: "male", voice_language: "de-DE"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{google_presentation_id: nil, name: nil, voice_gender: nil, voice_language: nil}

  setup :verify_on_exit!

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
      user = Factory.insert(:user, admin: true)
      conn = %{conn | assigns: %{current_user: user}}

      conn = delete conn, lesson_path(conn, :delete, lesson)
      assert redirected_to(conn) == lesson_path(conn, :index)
      # assert_error_sent 404, fn ->
      #   get conn, lesson_path(conn, :show, lesson)
      # end
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

  describe "#invalidate_all_audio_hashes" do
    setup do
      slide_1 = Factory.insert(:slide, audio_hash: "VALID_HASH")
      slide_2 = Factory.insert(:slide, audio_hash: "VALID_HASH")
      lesson = Factory.insert(:lesson, google_presentation_id: "1", slides: [slide_1, slide_2])

      [lesson: lesson]
    end

    test "should reset all audio hashes", %{conn: conn, lesson: lesson} do
      assert Enum.map(lesson.slides, fn(slide) -> slide.audio_hash end) != [nil, nil]

      conn = post conn, lesson_path(conn, :invalidate_all_audio_hashes, lesson)
      assert redirected_to(conn) == lesson_path(conn, :show, lesson)

      lesson = Platform.Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn(slide) -> slide.audio_hash end) == [nil, nil]
    end

    test "should also reset all video hashes", %{conn: conn, lesson: lesson} do
      assert Enum.map(lesson.slides, fn(slide) -> slide.audio_hash end) != [nil, nil]

      conn = post conn, lesson_path(conn, :invalidate_all_audio_hashes, lesson)
      assert redirected_to(conn) == lesson_path(conn, :show, lesson)

      lesson = Platform.Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn(slide) -> slide.video_hash end) == [nil, nil]
    end
  end

  describe "#sync" do
    setup :create_lesson

    test "should call Core.sync_lesson with correct lesson", %{conn: conn, lesson: lesson} do
      with_mock Platform.Core, [:passthrough], [sync_lesson: fn _ -> "" end] do
        conn = post conn, lesson_path(conn, :sync, lesson)
        assert redirected_to(conn) == lesson_path(conn, :show, lesson)

        assert called Platform.Core.sync_lesson(%{id: lesson.id})
      end
    end

    test "should handle error from Core.sync_lesson", %{conn: conn, lesson: lesson} do
      with_mock Platform.Core, [:passthrough], [sync_lesson: fn _ -> {:error, %{message: "message", status: "status"}} end] do
        conn = post conn, lesson_path(conn, :sync, lesson)

        assert called Platform.Core.sync_lesson(%{id: lesson.id})
        assert get_flash(conn, :error) == "status : message"
        assert redirected_to(conn) == lesson_path(conn, :show, lesson)
      end
    end
  end

  describe "#download_all_thumbs!" do
    setup :create_lesson

    test "should call Core.download_all_thumbs! with a lesson", %{conn: conn, lesson: lesson} do
      Platform.SlidesAPIMock
      |> expect(:download_slide_thumb!, length(lesson.slides), fn _x, _y, z -> z end)

      conn = post conn, lesson_path(conn, :download_all_thumbs, lesson)

      assert redirected_to(conn) == lesson_path(conn, :show, lesson)
      assert get_flash(conn, :info) == "All thumbs downloaded..."
    end
  end

  defp create_lesson(_) do
    slide_1 = Factory.insert(:slide)
    slide_2 = Factory.insert(:slide)
    lesson = Factory.insert(:lesson, google_presentation_id: "1", slides: [slide_1, slide_2])
    {:ok, lesson: lesson}
  end
end

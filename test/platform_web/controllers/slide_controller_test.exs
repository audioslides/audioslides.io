defmodule PlatformWeb.SlideControllerTest do
  use PlatformWeb.ConnCase

  alias Platform.VideoConverter.TestAdapter

  setup [:create_lesson, :create_slide, :set_current_user_as_admin]

  describe "#show" do
    test "renders a slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = get(conn, lesson_slide_path(conn, :show, lesson, slide))
      assert html_response(conn, 200) =~ slide.name
    end
  end

  describe "#edit" do
    test "renders form for editing chosen slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = get(conn, lesson_slide_path(conn, :edit, lesson, slide))
      assert html_response(conn, 200) =~ slide.name
    end
  end

  describe "#generate_video" do
    test "renders form for editing chosen slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = post(conn, lesson_slide_path(conn, :generate_video, lesson, slide))
      assert redirected_to(conn) == lesson_slide_path(conn, :show, lesson, slide)
      assert length(TestAdapter.generate_video_list()) == 1
    end
  end

  describe "#get_speech_preview" do
    test "returns a binary stream of audio/mpeg", %{conn: conn, lesson: lesson, slide: slide} do
      conn = post(conn, lesson_slide_path(conn, :get_speech_preview, lesson, slide))

      assert response_content_type(conn, :mpeg) =~ "audio/mpeg; charset=utf-8"
      assert response(conn, 200) =~ <<73, 68, 51, 4, 0, 0, 0, 0, 0>>
    end
  end

  # Private functions
  defp create_lesson(_) do
    lesson = Factory.insert(:lesson)
    {:ok, lesson: lesson}
  end

  defp create_slide(%{lesson: lesson}) do
    slide = Factory.insert(:slide, lesson: lesson, video_hash: "B")
    {:ok, slide: slide}
  end

  defp set_current_user_as_admin(%{conn: conn}) do
    user = Factory.insert(:user, admin: true)
    conn = %{conn | assigns: %{current_user: user}}
    {:ok, conn: conn}
  end
end

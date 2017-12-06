defmodule PlatformWeb.SlideControllerTest do
  use PlatformWeb.ConnCase
  import Mox

  alias Platform.VideoConverter.TestAdapter

  @update_attrs %{complete_percent: 55}
  @invalid_attrs %{complete_percent: 999}

  setup :set_current_user_as_admin
  setup :create_lesson

  describe "#show" do
    setup :create_slide

    test "renders a slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = get(conn, lesson_slide_path(conn, :show, lesson, slide))
      assert html_response(conn, 200) =~ slide.name
    end
  end

  describe "#edit" do
    setup :create_slide

    test "renders form for editing chosen slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = get(conn, lesson_slide_path(conn, :edit, lesson, slide))
      assert html_response(conn, 200) =~ slide.name
    end
  end

  describe "#update" do
    setup :create_slide

    test "redirects when data is valid", %{conn: orig_conn, lesson: lesson, slide: slide} do
      Platform.SlidesAPIMock
      |> expect(:update_speaker_notes!, fn _x, _y, z -> z end)

      conn = put(orig_conn, lesson_slide_path(orig_conn, :update, lesson, slide), slide: @update_attrs)
      assert redirected_to(conn) == lesson_slide_path(conn, :show, lesson, slide)

      conn = get(orig_conn, lesson_slide_path(orig_conn, :show, lesson, slide))
      assert html_response(conn, 200) =~ "55%"
    end

    test "renders errors when data is invalid", %{conn: conn, lesson: lesson, slide: slide} do
      conn = put(conn, lesson_slide_path(conn, :update, lesson, slide), slide: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit slide"
    end
  end

  describe "#generate_video" do
    setup :create_slide

    test "renders form for editing chosen slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = post(conn, lesson_slide_path(conn, :generate_video, lesson, slide))
      assert redirected_to(conn) == lesson_slide_path(conn, :show, lesson, slide)
      assert length(TestAdapter.generate_video_list()) == 1
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

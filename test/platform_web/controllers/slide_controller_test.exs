defmodule PlatformWeb.SlideControllerTest do
  use PlatformWeb.ConnCase

  import Platform.Speech.Mock.System
  import Mock

  setup :create_lesson

  describe "#show" do
    setup :create_slide

    test "renders form for editing chosen slide", %{conn: conn, lesson: lesson, slide: slide} do
      conn = get conn, lesson_slide_path(conn, :show, lesson, slide)
      assert html_response(conn, 200) =~ slide.name
    end
  end

  describe "#generate_video" do
    setup :create_slide

    # test "renders form for editing chosen slide", %{conn: conn, lesson: lesson, slide: slide} do
    #   with_mock System, [cmd: &cmd(&1, &2, &3), cmd: &cmd(&1, &2)] do
    #     conn = post conn, lesson_slide_path(conn, :generate_video, lesson, slide)
    #     assert html_response(conn, 200) =~ slide.name
    #   end
    # end
  end

  # Private functions
  defp create_lesson(_) do
    lesson = Factory.insert(:lesson)
    {:ok, lesson: lesson}
  end

  defp create_slide(%{lesson: lesson}) do
    slide = Factory.insert(:slide, lesson: lesson)
    {:ok, slide: slide}
  end
end

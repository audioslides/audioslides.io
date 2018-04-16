defmodule PlatformWeb.LessonControllerTest do
  use PlatformWeb.ConnCase

  alias GoogleApi.Slides.V1.Model.Presentation

  import Mock
  import Mox

  @create_attrs %{
    google_presentation_id: "some-google_presentation_id",
    name: "some name",
    voice_gender: "male",
    voice_language: "de-DE"
  }
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{google_presentation_id: nil, name: nil, voice_gender: nil, voice_language: nil}

  setup [:set_current_user_as_admin, :verify_on_exit!]

  describe "#index" do
    setup [:create_lesson]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      conn = get(conn, lesson_path(conn, :index))
      assert html_response(conn, 200) =~ lesson.name
    end
  end

  describe "#new" do
    test "renders form", %{conn: conn} do
      conn = get(conn, lesson_path(conn, :new))
      assert html_response(conn, 200) =~ "New Lesson"
    end
  end

  describe "#show" do
    test "displays the video", %{conn: conn} do
      lesson = Factory.insert(:lesson, name: "Lesson name")
      conn = get(conn, lesson_path(conn, :show, lesson.id))
      assert html_response(conn, 200) =~ lesson.name
    end
  end

  describe "#manage" do
    test "manage the video", %{conn: conn} do
      lesson = Factory.insert(:lesson, name: "Lesson name")
      conn = get(conn, lesson_path(conn, :manage, lesson.id))
      assert html_response(conn, 200) =~ lesson.name
      assert html_response(conn, 200) =~ "Manage Video"
    end
  end

  describe "#create" do
    setup [:create_lesson]

    test "redirects to show when data is valid", %{conn: orig_conn, lesson: lesson} do

      google_presentation = %Presentation{
        presentationId: lesson.google_presentation_id,
        slides: []
      }

      Platform.SlidesAPIMock
      |> expect(:get_presentation, fn _x -> {:ok, google_presentation} end)

      conn = post(orig_conn, lesson_path(orig_conn, :create), lesson: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == lesson_path(conn, :manage, id)

      conn = get(orig_conn, lesson_path(orig_conn, :manage , id))
      assert html_response(conn, 200) =~ "name"
    end

    test "redirects to show when data is valid with google slide url", %{conn: orig_conn} do
      attrs_with_google_slide_url = %{
        google_presentation_id:
          "https://docs.google.com/presentation/d/1tgbdANGoW8BGI-S-_DcP0XsxhoaTO_KConY7-R3FnkM/edit#slide=id.g299abd216d_0_525",
        name: "some name",
        voice_gender: "male",
        voice_language: "de-DE"
      }

      google_presentation = %Presentation{
        presentationId: "1",
        slides: []
      }

      Platform.SlidesAPIMock
      |> expect(:get_presentation, fn _x -> {:ok, google_presentation} end)

      conn = post(orig_conn, lesson_path(orig_conn, :create), lesson: attrs_with_google_slide_url)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == lesson_path(conn, :manage, id)

      conn = get(orig_conn, lesson_path(orig_conn, :manage, id))
      assert html_response(conn, 200) =~ "name"

      assert Platform.Core.get_lesson!(id).google_presentation_id == "1tgbdANGoW8BGI-S-_DcP0XsxhoaTO_KConY7-R3FnkM"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, lesson_path(conn, :create), lesson: @invalid_attrs)
      assert html_response(conn, 200) =~ "New lesson"
    end
  end

  describe "#edit" do
    setup [:create_lesson]

    test "renders form for editing chosen lesson", %{conn: conn, lesson: lesson} do
      conn = get(conn, lesson_path(conn, :edit, lesson))
      assert html_response(conn, 200) =~ "Edit lesson"
    end
  end

  describe "#update" do
    setup [:create_lesson]

    test "redirects when data is valid", %{conn: orig_conn, lesson: lesson} do
      conn = put(orig_conn, lesson_path(orig_conn, :update, lesson), lesson: @update_attrs)
      assert redirected_to(conn) == lesson_path(conn, :show, lesson)

      conn = get(orig_conn, lesson_path(orig_conn, :show, lesson))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, lesson: lesson} do
      conn = put(conn, lesson_path(conn, :update, lesson), lesson: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit lesson"
    end
  end

  describe "#delete" do
    setup [:create_lesson]

    test "deletes chosen lesson", %{conn: conn, lesson: lesson} do
      conn = delete(conn, lesson_path(conn, :delete, lesson))
      assert redirected_to(conn) == lesson_path(conn, :index)
      # assert_error_sent 404, fn ->
      #   get conn, lesson_path(conn, :show, lesson)
      # end
    end
  end

  describe "#generate_video" do
    setup [:create_lesson]

    alias Platform.VideoConverter.TestAdapter

    test "should redirect to manage", %{conn: conn, lesson: lesson} do
      conn = post(conn, lesson_path(conn, :generate_video, lesson))
      assert redirected_to(conn) == lesson_path(conn, :manage, lesson)

      # wait for async process to complete
      # ref = conn.private.generate_video_task.ref
      # assert_receive {:DOWN, ^ref, :process, _, :normal}, 500

      #assert length(TestAdapter.generate_video_list()) == 1
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
      assert Enum.map(lesson.slides, fn slide -> slide.audio_hash end) != [nil, nil]

      conn = post(conn, lesson_path(conn, :invalidate_all_audio_hashes, lesson))
      assert redirected_to(conn) == lesson_path(conn, :manage, lesson)

      lesson = Platform.Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn slide -> slide.audio_hash end) == [nil, nil]
    end

    test "should also reset all video hashes", %{conn: conn, lesson: lesson} do
      assert Enum.map(lesson.slides, fn slide -> slide.audio_hash end) != [nil, nil]

      conn = post(conn, lesson_path(conn, :invalidate_all_audio_hashes, lesson))
      assert redirected_to(conn) == lesson_path(conn, :manage, lesson)

      lesson = Platform.Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn slide -> slide.video_hash end) == [nil, nil]
    end
  end

  describe "#invalidate_all_video_hashes" do
    setup do
      slide_1 = Factory.insert(:slide, video_hash: "VALID_HASH")
      slide_2 = Factory.insert(:slide, video_hash: "VALID_HASH")
      lesson = Factory.insert(:lesson, google_presentation_id: "1", slides: [slide_1, slide_2])

      [lesson: lesson]
    end

    test "should also reset all video hashes", %{conn: conn, lesson: lesson} do
      assert Enum.map(lesson.slides, fn slide -> slide.video_hash end) != [nil, nil]

      conn = post(conn, lesson_path(conn, :invalidate_all_video_hashes, lesson))
      assert redirected_to(conn) == lesson_path(conn, :manage, lesson)

      lesson = Platform.Core.get_lesson_with_slides!(lesson.id)

      assert Enum.map(lesson.slides, fn slide -> slide.video_hash end) == [nil, nil]
    end
  end

  describe "#sync" do
    setup [:create_lesson]

    test "should call Core.sync_lesson with correct lesson", %{conn: conn, lesson: lesson} do
      with_mock Platform.Core, [:passthrough], sync_lesson: fn _ -> "" end do
        conn = post(conn, lesson_path(conn, :sync, lesson))
        assert redirected_to(conn) == lesson_path(conn, :manage, lesson)

        assert called(Platform.Core.sync_lesson(%{id: lesson.id}))
      end
    end

    test "should handle error from Core.sync_lesson", %{conn: conn, lesson: lesson} do
      with_mock Platform.Core, [:passthrough],
        sync_lesson: fn _ -> {:error, %{message: "message", status: "status"}} end do
        conn = post(conn, lesson_path(conn, :sync, lesson))

        assert called(Platform.Core.sync_lesson(%{id: lesson.id}))
        assert get_flash(conn, :error) == "status : message"
        assert redirected_to(conn) == lesson_path(conn, :manage, lesson)
      end
    end
  end

  describe "#download_all_thumbs!" do
    setup [:create_lesson]

    test "should call Core.download_all_thumbs! with a lesson", %{conn: conn, lesson: lesson} do
      Platform.SlidesAPIMock
      |> expect(:download_slide_thumb!, length(lesson.slides), fn _x, _y, z -> z end)

      conn = post(conn, lesson_path(conn, :download_all_thumbs, lesson))

      assert redirected_to(conn) == lesson_path(conn, :manage, lesson)
      assert get_flash(conn, :info) == "All thumbs downloaded..."
    end
  end

  defp create_lesson(_) do
    slide_1 = Factory.insert(:slide)
    slide_2 = Factory.insert(:slide)
    lesson = Factory.insert(:lesson, google_presentation_id: "1", slides: [slide_1, slide_2])
    {:ok, lesson: lesson}
  end

  defp set_current_user_as_admin(%{conn: conn}) do
    user = Factory.insert(:user, admin: true)
    conn = %{conn | assigns: %{current_user: user}}
    {:ok, conn: conn}
  end
end

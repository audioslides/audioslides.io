defmodule PlatformWeb.LessonController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Core.Schema.Lesson
  alias Platform.VideoProcessingState

  alias Platform.Video
  alias PlatformWeb.AccessHelper
  alias PlatformWeb.LessonChannel

  def index(conn, _params) do
    Lesson
    |> authorize_action!(conn)

    lessons = AccessHelper.list_lessons(conn)
    render(conn, "index.html", lessons: lessons)
  end

  def new(conn, _params) do
    Lesson
    |> authorize_action!(conn)

    changeset = Core.change_lesson(%Lesson{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"lesson" => lesson_params}) do
    Lesson
    |> authorize_action!(conn)

    case Core.create_lesson(lesson_params) do
      {:ok, lesson} ->
        conn
        |> put_flash(:info, "Lesson created successfully.")
        |> redirect(to: lesson_path(conn, :show, lesson))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson!()
      |> authorize_action!(conn)

    render(conn, "show.html", lesson: lesson)
  end

  def manage(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    render(conn, "manage.html", lesson: lesson)
  end

  def edit(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson!()
      |> authorize_action!(conn)

    # Video.convert_lesson(lesson.google_presentation_id)
    changeset = Core.change_lesson(lesson)
    render(conn, "edit.html", lesson: lesson, changeset: changeset)
  end

  def update(conn, %{"id" => id, "lesson" => lesson_params}) do
    lesson =
      id
      |> Core.get_lesson!()
      |> authorize_action!(conn)

    case Core.update_lesson(lesson, lesson_params) do
      {:ok, lesson} ->
        conn
        |> put_flash(:info, "Lesson updated successfully.")
        |> redirect(to: lesson_path(conn, :show, lesson))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", lesson: lesson, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson!()
      |> authorize_action!(conn)

    {:ok, _lesson} = Core.delete_lesson(lesson)

    conn
    |> put_flash(:info, "Lesson deleted successfully.")
    |> redirect(to: lesson_path(conn, :index))
  end

  def sync(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    case Core.sync_lesson(lesson) do
      {:error, error} ->
        conn
        |> put_flash(:error, "#{error.status} : #{error.message}")
        |> redirect(to: lesson_path(conn, :manage, lesson))

      _ ->
        conn
        |> put_flash(:info, "Lesson synced...")
        |> redirect(to: lesson_path(conn, :manage, lesson))
    end
  end

  def generate_video(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

      lesson
      |> Video.convert_lesson_to_video()
      |> Enum.each(fn(_) -> broadcast_processing_update(id) end)

    conn
    |> put_flash(:info, "Generating Lesson video...")
    #|> put_private(:generate_video_task, task_ref)
    |> redirect(to: lesson_path(conn, :manage, lesson))
  end

  def merge_videos(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    task_ref =
      Task.async fn ->
        Video.merge_videos(lesson)
        broadcast_processing_update(id)
      end

    conn
    |> put_flash(:info, "Merge all videos...")
    |> put_private(:merge_videos_task, task_ref)
    |> redirect(to: lesson_path(conn, :manage, lesson))
  end

  def broadcast_processing_update(id) do
    lesson = Core.get_lesson_with_slides!(id)
    LessonChannel.broadcast_processing_to_socket(lesson)
  end

  def invalidate_all_audio_hashes(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    Core.invalidate_all_audio_hashes(lesson)
    Core.invalidate_all_video_hashes(lesson)

    conn
    |> put_flash(:info, "All audio hashed invalidated...")
    |> redirect(to: lesson_path(conn, :manage, lesson))
  end

  def invalidate_all_video_hashes(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    Core.invalidate_all_video_hashes(lesson)

    conn
    |> put_flash(:info, "All audio hashed invalidated...")
    |> redirect(to: lesson_path(conn, :manage, lesson))
  end

  def download_all_thumbs(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    Core.download_all_thumbs!(lesson)

    conn
    |> put_flash(:info, "All thumbs downloaded...")
    |> redirect(to: lesson_path(conn, :manage, lesson))
  end
end

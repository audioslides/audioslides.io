defmodule PlatformWeb.LessonController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Core.Schema.Lesson

  alias Platform.Video

  def index(conn, _params) do
    lessons = Core.list_lessons()
    render(conn, "index.html", lessons: lessons)
  end

  def new(conn, _params) do
    Lesson |> authorize_action!(conn)

    changeset = Core.change_lesson(%Lesson{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"lesson" => lesson_params}) do
    Lesson |> authorize_action!(conn)

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
    Lesson |> authorize_action!(conn)

    lesson = Core.get_lesson_with_slides!(id)
    render(conn, "show.html", lesson: lesson)
  end

  def edit(conn, %{"id" => id}) do
    Lesson |> authorize_action!(conn)

    lesson = Core.get_lesson!(id)
    #Video.convert_lesson(lesson.google_presentation_id)
    changeset = Core.change_lesson(lesson)
    render(conn, "edit.html", lesson: lesson, changeset: changeset)
  end

  def update(conn, %{"id" => id, "lesson" => lesson_params}) do
    Lesson |> authorize_action!(conn)

    lesson = Core.get_lesson!(id)

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
    Lesson |> authorize_action!(conn)

    lesson = Core.get_lesson!(id)
    {:ok, _lesson} = Core.delete_lesson(lesson)

    conn
    |> put_flash(:info, "Lesson deleted successfully.")
    |> redirect(to: lesson_path(conn, :index))
  end

  def sync(conn, %{"id" => id}) do
    Lesson |> authorize_action!(conn)

    lesson = Core.get_lesson_with_slides!(id)

    case Core.sync_lesson(lesson) do
      {:error, error} ->
        conn
        |> put_flash(:error, "#{error.status} : #{error.message}")
        |> redirect(to: lesson_path(conn, :show, lesson))
      _ ->
        conn
        |> put_flash(:info, "Lesson synced...")
        |> redirect(to: lesson_path(conn, :show, lesson))
    end
  end

  def generate_video(conn, %{"id" => id}) do
    Lesson |> authorize_action!(conn)

    lesson = Core.get_lesson_with_slides!(id)

    Video.convert_lesson_to_video(lesson)

    conn
    |> put_flash(:info, "Generating Lesson video...")
    |> redirect(to: lesson_path(conn, :show, lesson))
  end

end

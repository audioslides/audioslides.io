defmodule PlatformWeb.LessonController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Core.Schema.Lesson

  alias Platform.Video
  alias PlatformWeb.AccessHelper

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
        |> redirect(to: lesson_path(conn, :show, lesson))

      _ ->
        conn
        |> put_flash(:info, "Lesson synced...")
        |> redirect(to: lesson_path(conn, :show, lesson))
    end
  end

  def generate_video(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)


    spawn fn -> Video.convert_lesson_to_video(lesson) end
    Process.register self(), :lesson_controller

    create_stream() |> Enum.each &IO.inspect&1

    conn
    |> put_flash(:info, "Generating Lesson video...")
    |> redirect(to: lesson_path(conn, :show, lesson))
  end

  defp create_stream do
    Stream.resource(
      fn -> %{} end,
      fn(%{}) -> loop() end,
      fn(_) -> nil end)
  end

  defp loop do
    receive do
      {:step, state} -> {state, state}
      {:done, state} -> {:halt, state}
    end
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
    |> redirect(to: lesson_path(conn, :show, lesson))
  end

  def download_all_thumbs(conn, %{"id" => id}) do
    lesson =
      id
      |> Core.get_lesson_with_slides!()
      |> authorize_action!(conn)

    Process.register self(), :lesson_controller
    spawn fn -> Core.download_all_thumbs!(lesson) end


    create_stream() |> Enum.each &IO.inspect&1

    conn
    |> put_flash(:info, "All thumbs downloaded...")
    |> redirect(to: lesson_path(conn, :show, lesson))
  end
end

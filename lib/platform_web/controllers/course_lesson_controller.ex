defmodule PlatformWeb.CourseLessonController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Core.Schema.CourseLesson

  def new(conn, %{"course_id" => course_id}) do
    course = Core.get_course!(course_id)

    changeset = Core.change_course_lesson(course, %CourseLesson{})
    render(conn, "new.html", course: course, changeset: changeset, collections: collections(conn))
  end

  def create(conn, %{"course_id" => course_id, "course_lesson" => course_lesson_params}) do
    course = Core.get_course!(course_id)

    case Core.create_course_lesson(course, course_lesson_params) do
      {:ok, _course_lesson} ->
        conn
        |> put_flash(:info, "Course lesson created successfully.")
        |> redirect(to: course_path(conn, :show, course))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", course: course, changeset: changeset, collections: collections(conn))
    end
  end

  def edit(conn, %{"course_id" => course_id, "id" => id}) do
    course = Core.get_course!(course_id)

    course_lesson = Core.get_course_lesson!(course, id)
    changeset = Core.change_course_lesson(course, course_lesson)
    render(conn, "edit.html", course: course, course_lesson: course_lesson, changeset: changeset, collections: collections(conn))
  end

  def update(conn, %{"course_id" => course_id, "id" => id, "course_lesson" => course_lesson_params}) do
    course = Core.get_course!(course_id)

    course_lesson = Core.get_course_lesson!(course, id)

    case Core.update_course_lesson(course, course_lesson, course_lesson_params) do
      {:ok, _course_lesson} ->
        conn
        |> put_flash(:info, "Course lesson updated successfully.")
        |> redirect(to: course_path(conn, :show, course))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", course: course, course_lesson: course_lesson, changeset: changeset, collections: collections(conn))
    end
  end

  def delete(conn, %{"course_id" => course_id, "id" => id}) do
    course = Core.get_course!(course_id)

    course_lesson = Core.get_course_lesson!(course, id)
    {:ok, _course_lesson} = Core.delete_course_lesson(course, course_lesson)

    conn
    |> put_flash(:info, "Course lesson deleted successfully.")
    |> redirect(to: course_path(conn, :show, course))
  end

  # Private functions
  defp collections(_conn) do
    %{
      lessons:
        Core.list_lessons()
    }
  end
end

defmodule PlatformWeb.CourseController do
  use PlatformWeb, :controller

  alias Platform.Core
  alias Platform.Core.Schema.Course

  alias PlatformWeb.AccessHelper

  def index(conn, _params) do
    Course
    |> authorize_action!(conn)

    courses = Core.list_courses()
    render(conn, "index.html", courses: courses)
  end

  def new(conn, _params) do
    Course
    |> authorize_action!(conn)

    changeset = Core.change_course(%Course{})
    render(conn, "new.html", changeset: changeset, collections: collections(conn))
  end

  def create(conn, %{"course" => course_params}) do
    Course
    |> authorize_action!(conn)

    case Core.create_course(course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, collections: collections(conn))
    end
  end

  def show(conn, %{"id" => id}) do
    course =
      id
      |> Core.get_course_with_lessons!()
      |> authorize_action!(conn)

    render(conn, "show.html", course: course)
  end

  def edit(conn, %{"id" => id}) do
    course =
      id
      |> Core.get_course_with_lessons!()
      |> authorize_action!(conn)

    changeset = Core.change_course(course)

    render(
      conn,
      "edit.html",
      course: course,
      changeset: changeset,
      collections: collections(conn)
    )
  end

  def update(conn, %{"id" => id, "course" => course_params}) do
    course =
      id
      |> Core.get_course!()
      |> authorize_action!(conn)

    case Core.update_course(course, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(
          conn,
          "edit.html",
          course: course,
          changeset: changeset,
          collections: collections(conn)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    course =
      id
      |> Core.get_course!()
      |> authorize_action!(conn)

    {:ok, _course} = Core.delete_course(course)

    conn
    |> put_flash(:info, "Course deleted successfully.")
    |> redirect(to: course_path(conn, :index))
  end

  # Private methods
  defp collections(conn) do
    %{
      lessons: AccessHelper.list_lessons(conn)
    }
  end
end

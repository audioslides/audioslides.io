defmodule Platform.Core do
  @moduledoc """
  The Core context.
  """
  import Ecto.Query, warn: false

  alias Platform.Repo
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide
  alias Platform.Core.Schema.Course
  alias Platform.Core.LessonSync

  ### ################################################################### ###
  ### Lesson                                                        ###
  ### ################################################################### ###
  def list_lessons do
    Lesson
    |> Repo.all
    |> Repo.preload(slides: Slide |> Ecto.Query.order_by([asc: :position]))
  end

  def get_lesson!(id) do
    Repo.get!(Lesson, id)
  end

  def get_lesson_by_google_presentation_id!(id) do
    Repo.get_by!(Lesson, google_presentation_id: id)
  end

  def get_lesson_with_slides!(id) do
    Lesson
    |> Repo.get!(id)
    |> Repo.preload(slides: Slide |> Ecto.Query.order_by([asc: :position]))
  end

  def create_lesson(attrs \\ %{}) do
    %Lesson{}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
  end

  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
  end

  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  def change_lesson(%Lesson{} = lesson) do
    Lesson.changeset(lesson, %{})
  end

  ### ################################################################### ###
  ### Slide                                                               ###
  ### ################################################################### ###
  def get_slide!(%Lesson{} = lesson, id) do
    lesson
    |> Ecto.assoc(:slides)
    |> Repo.get!(id)
  end

  def create_slide(%Lesson{} = lesson, attrs \\ %{}) do
    %Slide{lesson: lesson}
    |> Slide.changeset(attrs)
    |> Repo.insert()
  end

  def update_slide(%Slide{} = slide, attrs) do
    slide
    |> Slide.changeset(attrs)
    |> Repo.update()
  end

  def delete_slide(%Slide{} = slide) do
    Repo.delete(slide)
  end

  def change_slide(%Lesson{} = lesson, %Slide{} = slide) do
    Slide.changeset(slide, %{lesson: lesson})
  end

  def sync_lesson(lesson) do
    LessonSync.sync_slides(lesson)
  end

  alias Platform.Core.Schema.Course

  @doc """
  Returns the list of courses.

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a course.

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Course.

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  """
  def change_course(%Course{} = course) do
    Course.changeset(course, %{})
  end
end

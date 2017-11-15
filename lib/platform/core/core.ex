defmodule Platform.Core do
  @moduledoc """
  The Core context.
  """
  import Ecto.Query, warn: false

  alias Platform.Repo
  alias Platform.Core.Schema.Lesson
  alias Platform.Core.Schema.Slide
  alias Platform.Core.Schema.Course
  alias Platform.Core.Schema.CourseLesson
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
    Lesson
    |> Repo.get!(id)
  end

  def get_lesson_by_google_presentation_id!(id) do
    Lesson
    |> Repo.get_by!(google_presentation_id: id)
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
  def get_slide!(id) do
    Slide
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

  def update_slide_audio_hash(%Slide{} = slide, hash) do
    slide
    |> Slide.changeset(%{audio_hash: hash})
    |> Repo.update()
  end

  ### ################################################################### ###
  ### Courses                                                             ###
  ### ################################################################### ###

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
  def get_course!(id) do
    Course
    |> Repo.get!(id)
  end

  def get_course_with_lessons!(id) do
    Course
    |> Repo.get!(id)
    |> Repo.preload([course_lessons: :lesson])
  end

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

  ### ################################################################### ###
  ### CourseLesson                                                        ###
  ### ################################################################### ###
  def get_course_lesson!(%Course{} = course, id) do
    course
    |> Ecto.assoc(:course_lessons)
    |> Repo.get!(id)
    |> Repo.preload(:lesson)
  end

  def create_course_lesson(%Course{} = course, attrs \\ %{}) do
    %CourseLesson{course: course}
    |> CourseLesson.changeset(attrs)
    |> Repo.insert()
  end

  def update_course_lesson(%Course{} = _course, %CourseLesson{} = course_lesson, attrs) do
    course_lesson
    |> CourseLesson.changeset(attrs)
    |> Repo.update()
  end

  def delete_course_lesson(%Course{} = _course, %CourseLesson{} = course_lesson) do
    Repo.delete(course_lesson)
  end

  def change_course_lesson(%Course{} = course, %CourseLesson{} = course_lesson) do
    CourseLesson    .changeset(course_lesson, %{course: course})
  end
end

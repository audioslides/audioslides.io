defmodule Platform.Core.Schema.CourseLesson do
  @moduledoc """
  Connects a course with a lesson
  Course -> CourseLesson -> Lesson

  Additionaly adds a sort order.
  """
  import Ecto.Changeset

  use Ecto.Schema

  alias Platform.Core.Schema.Course
  alias Platform.Core.Schema.Lesson

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "course_lessons" do
    field(:position, :integer)

    belongs_to(:course, Course)
    belongs_to(:lesson, Lesson)
  end

  @doc false
  @fields [:position, :lesson_id]
  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, @fields)
    |> validate_required([:position, :lesson_id])
  end
end

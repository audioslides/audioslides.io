defmodule Platform.Core.Schema.CourseLesson do
  import Ecto.Changeset

  use Ecto.Schema

  alias Platform.Core.Schema.Course
  alias Platform.Core.Schema.Lesson

  schema "course_lessons" do
    field :position, :integer

    belongs_to :course, Course
    belongs_to :lesson, Lesson
  end

  @doc false
  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, [:course_id, :lesson_id, :position])
    |> validate_required([:course_id, :lesson_id])
  end
end

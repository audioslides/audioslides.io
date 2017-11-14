defmodule Platform.Core.Schema.Course do
  import Ecto.Changeset

  use Ecto.Schema

  alias Platform.Core.Schema.Course
  alias Platform.Core.Schema.CourseContent
  alias Platform.Core.Schema.Lesson

  schema "courses" do
    field :name, :string
    timestamps()

    has_many :course_contents, CourseContent
    has_many :lessons, through: [:course_contents, :lesson]
  end

  @doc false
  def changeset(%Course{} = course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule Platform.Core.Schema.Course do
  import Ecto.Changeset

  use Ecto.Schema

  alias Platform.Core.Schema.Course
  alias Platform.Core.Schema.Lesson

  schema "courses" do
    field :name, :string
    timestamps()

    many_to_many :lessons, Lesson, join_through: "courses_lessons"
  end

  @doc false
  def changeset(%Course{} = course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

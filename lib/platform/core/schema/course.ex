defmodule Platform.Core.Schema.Course do
  import Ecto.Changeset
  use Ecto.Schema

  alias Platform.Core.Schema.CourseLesson

  schema "courses" do
    field :name, :string
    timestamps()

    has_many :course_lessons, CourseLesson
  end

  @doc false
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

defmodule Platform.Core.Schema.Course do
  import Ecto.Changeset
  use Ecto.Schema

  alias Platform.Core.Schema.CourseContent

  schema "courses" do
    field :name, :string
    timestamps()

    has_many :course_contents, CourseContent
    # has_many :lessons, through: [:course_contents, :lesson]
  end

  @doc false
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

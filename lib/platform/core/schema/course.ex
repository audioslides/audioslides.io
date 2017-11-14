defmodule Platform.Core.Schema.Course do
  @moduledoc """
  The schema for a course
  """

  import Ecto.Changeset
  use Ecto.Schema

  alias Platform.Core.Schema.CourseLesson

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "courses" do
    field :name, :string
    timestamps()

    has_many :course_lessons, CourseLesson
  end

  @doc false
  @fields [:name]
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required([:name])
  end
end

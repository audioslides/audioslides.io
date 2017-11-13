defmodule Platform.Core.Schema.Course do
  import Ecto.Changeset

  use Ecto.Schema

  alias Platform.Core.Schema.Course


  schema "courses" do
    field :name, :string
    timestamps()
  end

  @doc false
  def changeset(%Course{} = course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end

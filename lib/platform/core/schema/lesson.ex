defmodule Platform.Core.Schema.Lesson do
  @moduledoc """
  The lesson schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Accounts.Schema.User
  alias Platform.Core.Schema.Slide
  alias Platform.Core.Schema.CourseLesson

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "lessons" do
    field :visible, :boolean
    field :google_presentation_id, :string
    field :name, :string
    field :voice_gender, :string
    field :voice_language, :string
    field :synced_at, :utc_datetime
    timestamps()

    has_many :course_lessons, CourseLesson
    has_many :slides,  Slide, on_delete: :delete_all
    belongs_to :user, User
  end

  @doc false
  @fields [:visible, :google_presentation_id, :name, :voice_language, :voice_gender]
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required([:google_presentation_id, :name, :voice_language, :voice_gender])
    |> validate_inclusion(:voice_language, ["de-DE", "en-US"])
    |> validate_inclusion(:voice_gender, ["female", "male"])
  end
end

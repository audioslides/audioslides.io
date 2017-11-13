defmodule Platform.Core.Schema.Lesson do
  @moduledoc """
  The lesson schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    field :google_presentation_id, :string
    field :name, :string
    field :voice_gender, :string
    field :voice_language, :string
    field :synced_at, :utc_datetime
    timestamps()

    has_many :slides,  Platform.Core.Schema.Slide, on_delete: :delete_all
    belongs_to :user, Platform.Accounts.Schema.User
  end

  @doc false
  def changeset(%__MODULE__{} = lesson, attrs) do
    lesson
    |> cast(attrs, [:google_presentation_id, :name, :voice_language, :voice_gender])
    |> validate_required([:google_presentation_id, :name, :voice_language, :voice_gender])
    |> validate_inclusion(:voice_language, ["de-DE", "en-US"])
    |> validate_inclusion(:voice_gender, ["female", "male"])
  end
end

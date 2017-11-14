defmodule Platform.Core.Schema.Slide do
  @moduledoc """
  The slide schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "slides" do
    field :name, :string
    field :google_object_id, :string
    field :speaker_notes_hash, :string
    field :page_elements_hash, :string
    field :thumb_image_url, :string
    field :position, :integer
    field :synced_at, :utc_datetime
    timestamps()

    belongs_to :lesson, Platform.Core.Schema.Lesson
  end

  @doc false
  @fields [:google_object_id, :name, :position, :speaker_notes_hash, :page_elements_hash, :thumb_image_url, :synced_at]
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required([:google_object_id, :name, :position])
    |> unique_constraint(:google_object_id, name: :slides_lesson_id_google_object_id_index)
  end
end

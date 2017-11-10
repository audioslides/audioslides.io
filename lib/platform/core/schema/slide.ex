defmodule Platform.Core.Schema.Slide do
  @moduledoc """
  The slide schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "slides" do
    field :name, :string
    field :google_object_id, :string
    field :speaker_notes_hash, :string
    field :page_elements_hash, :string
    field :thumb_image_url, :string
    field :position, :integer
    field :synced_at, :utc_datetime
    timestamps()

    belongs_to :presentation, Platform.Core.Schema.Presentation
  end

  @doc false
  def changeset(%__MODULE__{} = slide, attrs) do
    slide
    |> cast(attrs, [:google_object_id, :name, :position, :speaker_notes_hash, :page_elements_hash, :thumb_image_url, :synced_at])
    |> validate_required([:google_object_id, :name, :position])
    |> unique_constraint(:google_object_id, name: :slides_presentation_id_google_object_id_index)
  end
end

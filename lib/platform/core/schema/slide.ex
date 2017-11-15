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
    field :position, :integer
    field :synced_at, :utc_datetime
    field :speaker_notes, :string
    field :audio_hash, :string
    field :audio_sync_pid, :string
    field :image_hash, :string
    field :image_sync_pid, :string
    field :video_hash, :string
    field :video_sync_pid, :string
    timestamps()

    belongs_to :lesson, Platform.Core.Schema.Lesson
  end

  @doc false
  @fields ~w(google_object_id name position speaker_notes_hash page_elements_hash synced_at speaker_notes audio_hash audio_sync_pid image_hash image_sync_pid video_hash video_sync_pid)a
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required([:google_object_id, :name, :position])
    |> unique_constraint(:google_object_id, name: :slides_lesson_id_google_object_id_index)
  end
end

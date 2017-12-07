defmodule Platform.Core.Schema.Slide do
  @moduledoc """
  The slide schema
  """
  use Ecto.Schema
  import Ecto.Changeset
  require require Ecto.Query

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "slides" do
    field(:name, :string)
    field(:google_object_id, :string)
    field(:speaker_notes_hash, :string)
    field(:page_elements_hash, :string)
    field(:position, :integer)
    field(:synced_at, :utc_datetime)
    field(:speaker_notes, :string)
    field(:audio_hash, :string)
    field(:audio_sync_pid, :string)
    field(:image_hash, :string)
    field(:image_sync_pid, :string)
    field(:video_hash, :string)
    field(:video_sync_pid, :string)
    field(:complete_percent, :integer, default: 0)
    timestamps()

    belongs_to(:lesson, Platform.Core.Schema.Lesson)
  end

  @doc false
  @fields ~w(google_object_id name position speaker_notes_hash page_elements_hash synced_at speaker_notes audio_hash audio_sync_pid image_hash image_sync_pid video_hash video_sync_pid complete_percent)a
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> validate_required([:google_object_id, :name, :position])
    |> unique_constraint(:google_object_id, name: :slides_lesson_id_google_object_id_index)
    |> validate_inclusion(:complete_percent, 0..100)
    |> update_total_complete_percent()
  end

  defp update_total_complete_percent(changeset) do
    changeset
    |> prepare_changes(fn changeset ->
        lesson = Ecto.assoc(changeset.data, :lesson)

        avg =
          __MODULE__
          |> Ecto.Query.where(lesson_id: ^changeset.data.lesson_id)
          |> changeset.repo.aggregate(:avg, :complete_percent)

        if avg do
          rounded_avg = round(Decimal.to_float(avg))

          lesson
          |> changeset.repo.update_all(set: [complete_percent: rounded_avg])
        end

        changeset
      end)
  end
end

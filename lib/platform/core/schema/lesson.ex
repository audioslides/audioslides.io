defmodule Platform.Core.Schema.Lesson do
  @moduledoc """
  The lesson schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Platform.Accounts.Schema.User
  alias Platform.Core.Schema.Slide
  alias Platform.Core.Schema.CourseLesson

  alias Platform.GoogleSlidesHelper

  @timestamps_opts [type: :utc_datetime, usec: false]
  schema "lessons" do
    field(:visible, :boolean)
    field(:google_presentation_id, :string)
    field(:name, :string)
    field(:voice_gender, :string)
    field(:voice_language, :string)
    field(:video_hash, :string)
    field(:video_sync_pid, :string)
    field(:synced_at, :utc_datetime)
    field(:complete_percent, :integer, default: 0)
    field(:duration, :integer, default: 0)
    timestamps()

    has_many(:course_lessons, CourseLesson)
    has_many(:slides, Slide, on_delete: :delete_all)
    belongs_to(:user, User)
  end

  @doc false
  @fields [:visible, :google_presentation_id, :name, :voice_language, :voice_gender, :video_hash, :video_sync_pid, :duration]
  def changeset(%__MODULE__{} = struct, attrs) do
    struct
    |> cast(attrs, @fields)
    |> extract_presentation_id()
    |> validate_format(:google_presentation_id, ~r{^[a-zA-Z0-9\-_]+$}, allow_blank: false)
    |> validate_required([:google_presentation_id, :name, :voice_language, :voice_gender])
    |> validate_inclusion(:voice_language, ["de-DE", "en-US"])
    |> validate_inclusion(:voice_gender, ["female", "male"])
  end

  def extract_presentation_id(%Ecto.Changeset{} = changeset) do
    input = get_field(changeset, :google_presentation_id)

    if input do
      google_presentation_id = GoogleSlidesHelper.extract_presentation_id(input)
      put_change(changeset, :google_presentation_id, google_presentation_id)
    else
      changeset
    end
  end
end

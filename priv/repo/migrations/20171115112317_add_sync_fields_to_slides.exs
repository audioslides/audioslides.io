defmodule Platform.Repo.Migrations.AddSyncFieldsToSlides do
  use Ecto.Migration

  def change do
    alter table(:slides) do
      add :speaker_notes, :text
      add :audio_hash, :string
      add :audio_sync_pid, :string
      add :image_hash, :string
      add :image_sync_pid, :string
      add :video_hash, :string
      add :video_sync_pid, :string
    end
  end
end

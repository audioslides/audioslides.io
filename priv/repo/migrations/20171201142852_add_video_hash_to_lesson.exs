defmodule Platform.Repo.Migrations.AddVideoHashToLesson do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :video_hash, :string
      add :video_sync_pid, :string
    end
  end
end

defmodule Platform.Repo.Migrations.AddSyncedAtToPresentations do
  use Ecto.Migration

  def change do
    alter table(:presentations) do
      add :synced_at, :utc_datetime
    end

    alter table(:slides) do
      add :synced_at, :utc_datetime
    end
  end
end

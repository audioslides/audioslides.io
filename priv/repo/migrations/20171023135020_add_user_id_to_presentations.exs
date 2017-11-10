defmodule Platform.Repo.Migrations.AddUserIdToPresentations do
  use Ecto.Migration

  def change do
    alter table(:presentations) do
      add :user_id, references(:users)
    end
  end
end

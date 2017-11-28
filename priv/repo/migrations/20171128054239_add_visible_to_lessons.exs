defmodule Platform.Repo.Migrations.AddVisibleToLessons do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :visible, :boolean, null: false, default: false
    end
  end
end

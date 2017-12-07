defmodule Platform.Repo.Migrations.AddCompletePercentToLessons do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :complete_percent, :integer, null: false, default: 0, limit: 3
    end
  end
end

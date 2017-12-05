defmodule Platform.Repo.Migrations.AddCompletePercentToSlides do
  use Ecto.Migration

  def change do
    alter table(:slides) do
      add :complete_percent, :integer, null: false, default: 0, limit: 3
    end
  end
end

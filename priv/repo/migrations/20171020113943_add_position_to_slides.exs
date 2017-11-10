defmodule Platform.Repo.Migrations.AddPositionToSlides do
  use Ecto.Migration

  def change do
    alter table(:slides) do
      add :position, :integer, null: false
    end
  end
end

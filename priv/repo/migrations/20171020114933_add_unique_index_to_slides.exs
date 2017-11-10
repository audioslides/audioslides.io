defmodule Platform.Repo.Migrations.AddUniqueIndexToSlides do
  use Ecto.Migration

  def change do
    create unique_index(:slides, [:presentation_id, :google_object_id])
  end
end

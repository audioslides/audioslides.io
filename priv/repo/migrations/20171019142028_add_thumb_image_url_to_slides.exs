defmodule Platform.Repo.Migrations.AddThumbImageUrlToSlides do
  use Ecto.Migration

  def change do
    create table(:slides) do
      add :presentation_id, references(:presentations), null: false
      add :name, :string, null: false

      add :google_object_id, :string
      add :speaker_notes_hash, :string
      add :page_elements_hash, :string
      add :thumb_image_url, :string

      timestamps()
    end
  end
end

defmodule Platform.Repo.Migrations.CreatePresentations do
  use Ecto.Migration

  def change do
    create table(:presentations) do
      add :google_presentation_id, :string
      add :name, :string
      add :voice_language, :string
      add :voice_gender, :string

      timestamps()
    end
  end
end

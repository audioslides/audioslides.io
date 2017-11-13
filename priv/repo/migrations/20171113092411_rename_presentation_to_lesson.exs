defmodule Platform.Repo.Migrations.RenamePresentationToLesson do
  use Ecto.Migration

  def change do
    rename table(:presentations), to: table(:lessons)
    execute "ALTER TABLE slides CHANGE COLUMN presentation_id lesson_id BIGINT UNSIGNED NOT NULL;"

    execute "ALTER TABLE slides DROP FOREIGN KEY slides_presentation_id_fkey; "
    drop index(:slides, [:presentation_id, :google_object_id])
    create unique_index(:slides, [:lesson_id, :google_object_id])

    execute "ALTER TABLE slides ADD CONSTRAINT slides_lesson_id_fkey FOREIGN KEY (`lesson_id`) REFERENCES `lessons` (`id`);"
  end
end

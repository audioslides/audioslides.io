defmodule Platform.Repo.Migrations.AddManyToManyRelationToLessonAndCourse do
  use Ecto.Migration

  def change do
    create table(:courses_lessons, primary_key: false) do
      add :course_id, references(:courses, on_delete: :delete_all)
      add :lesson_id, references(:lessons, on_delete: :delete_all)
      add :position, :integer
    end
  end
end

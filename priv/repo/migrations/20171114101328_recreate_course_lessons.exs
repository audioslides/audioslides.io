defmodule Platform.Repo.Migrations.RecreateCourseLessons do
  use Ecto.Migration

  def change do
    drop table(:courses_lessons)
    create table(:course_lessons) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :lesson_id, references(:lessons, on_delete: :delete_all), null: false
      add :position, :integer, null: false
    end
  end
end

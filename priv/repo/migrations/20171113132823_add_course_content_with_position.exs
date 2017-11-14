defmodule Platform.Repo.Migrations.AddCourseContentWithPosition do
  use Ecto.Migration

  def change do
    rename table(:courses_lessons), to: table(:course_contents)
  end
end

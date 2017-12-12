defmodule Platform.Repo.Migrations.AddDurationToLesson do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :duration, :integer, default: 0
    end
  end
end

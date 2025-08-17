defmodule Api.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string, null: false
      add :is_private, :boolean, default: false, null: false
      add :creator_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:rooms, [:creator_id])
  end
end

defmodule Api.Repo.Migrations.CreateRoomMembers do
  use Ecto.Migration

  def change do
    create table(:room_members) do
      add :encr_room_key, :binary
      add :room_id, references(:rooms, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:room_members, [:room_id])
    create index(:room_members, [:user_id])
  end
end

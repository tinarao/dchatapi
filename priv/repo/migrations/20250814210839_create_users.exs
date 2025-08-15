defmodule Api.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :bio, :string, null: true
      add :picture_url, :string, null: true
      add :password_hash, :string
      add :public_key, :string

      timestamps(type: :utc_datetime)
    end
  end
end

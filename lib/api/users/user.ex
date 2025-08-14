defmodule Api.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :public_key, :string
    field :bio, :string
    field :picture_url, :string
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :bio, :picture_url, :password_hash, :public_key])
    |> validate_required([:name, :bio, :picture_url, :password_hash, :public_key])
  end
end

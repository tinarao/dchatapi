defmodule Api.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :is_private, :boolean, default: false
    field :creator_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :is_private])
    |> validate_required([:name, :is_private])
  end
end

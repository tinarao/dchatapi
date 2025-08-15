defmodule Api.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Users

  @derive {
    Jason.Encoder,
    only: [:id, :name, :is_private, :creator_id, :inserted_at, :updated_at]
  }

  schema "rooms" do
    field :name, :string
    field :is_private, :boolean, default: false
    belongs_to :creator, Users.User
    # field :creator_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :is_private, :creator_id])
    |> validate_required([:name, :is_private])
  end
end

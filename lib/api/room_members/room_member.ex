defmodule Api.RoomMembers.RoomMember do
  use Ecto.Schema
  import Ecto.Changeset
  alias Api.Rooms
  alias Api.Users

  @derive {
    Jason.Encoder,
    only: [:id, :encr_room_key, :room_id, :user_id, :inserted_at, :updated_at]
  }

  schema "room_members" do
    field :encr_room_key, :binary
    belongs_to :room, Rooms.Room
    belongs_to :user, Users.User
    # field :room_id, :id
    # field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_member, attrs) do
    room_member
    |> cast(attrs, [:room_id, :user_id, :encr_room_key])
    |> validate_required([:encr_room_key])
  end
end

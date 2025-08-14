defmodule Api.RoomMembers.RoomMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "room_members" do
    field :ecnr_room_key, :binary
    field :room_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_member, attrs) do
    room_member
    |> cast(attrs, [:ecnr_room_key])
    |> validate_required([:ecnr_room_key])
  end
end

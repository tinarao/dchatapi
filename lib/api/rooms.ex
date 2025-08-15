defmodule Api.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo
  alias Api.Rooms.Room
  alias Api.RoomMembers

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  def get_room(id), do: Repo.get(Room, id)

  @doc """
  Returns a list of rooms created by user
  """
  def get_by_user_id(user_id) do
    Room
    |> where([r], r.creator_id == ^user_id)
    |> preload(:creator)
    |> Repo.all()
  end

  @doc """
  Returns a list of rooms user joined
  """
  def get_my_rooms(user_id) do
    RoomMembers.RoomMember
    |> where([rm], rm.user_id == ^user_id)
    |> preload([:room, :user])
    |> Repo.all()
  end

  def can_user_access_this_room?(_user_id, room) when room.is_public, do: true
  def can_user_access_this_room?(user_id, room) when room.creator_id === user_id, do: true

  def can_user_access_this_room?(user_id, room) do
    RoomMembers.exists?(user_id, room.id)
  end

  @doc """
  Returns a list of rooms where user participates (as Room objects)
  """
  def get_rooms_user_participates_in(user_id) do
    Room
    |> join(:inner, [r], rm in RoomMembers.RoomMember, on: r.id == rm.room_id)
    |> where([r, rm], rm.user_id == ^user_id)
    |> preload([:creator])
    |> Repo.all()
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end
end

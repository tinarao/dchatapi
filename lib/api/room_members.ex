defmodule Api.RoomMembers do
  @moduledoc """
  The RoomMembers context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo

  alias Api.RoomMembers.RoomMember

  @doc """
  Returns the list of room_members.

  ## Examples

      iex> list_room_members()
      [%RoomMember{}, ...]

  """
  def list_room_members do
    Repo.all(RoomMember)
  end

  @doc """
  Gets a single room_member.

  Raises `Ecto.NoResultsError` if the Room member does not exist.

  ## Examples

      iex> get_room_member!(123)
      %RoomMember{}

      iex> get_room_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room_member!(id), do: Repo.get!(RoomMember, id)

  @doc """
  Creates a room_member.

  ## Examples

      iex> create_room_member(%{field: value})
      {:ok, %RoomMember{}}

      iex> create_room_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room_member(attrs \\ %{}) do
    %RoomMember{}
    |> RoomMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room_member.

  ## Examples

      iex> update_room_member(room_member, %{field: new_value})
      {:ok, %RoomMember{}}

      iex> update_room_member(room_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room_member(%RoomMember{} = room_member, attrs) do
    room_member
    |> RoomMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room_member.

  ## Examples

      iex> delete_room_member(room_member)
      {:ok, %RoomMember{}}

      iex> delete_room_member(room_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room_member(%RoomMember{} = room_member) do
    Repo.delete(room_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room_member changes.

  ## Examples

      iex> change_room_member(room_member)
      %Ecto.Changeset{data: %RoomMember{}}

  """
  def change_room_member(%RoomMember{} = room_member, attrs \\ %{}) do
    RoomMember.changeset(room_member, attrs)
  end
end

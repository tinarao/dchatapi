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

  def exists?(user_id, room_id) do
    RoomMember
    |> where([rm], rm.user_id == ^user_id and rm.room_id == ^room_id)
    |> Repo.exists?()
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
  def get_room_member(id), do: Repo.get(RoomMember, id)

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
  Вызывается при создании комнаты.
  Создаёт две записи, связанные с комнатой (двух участников комнаты)
  """
  def on_room_create(room_id, first_user_data, second_user_data) do
    first_changeset = %{
      room_id: room_id,
      user_id: first_user_data.id,
      encr_room_key: first_user_data.key
    }

    second_changeset = %{
      room_id: room_id,
      user_id: second_user_data.id,
      encr_room_key: second_user_data.key
    }

    case Repo.transaction(fn ->
           {:ok, member1} =
             %RoomMember{}
             |> RoomMember.changeset(first_changeset)
             |> Repo.insert()

           {:ok, member2} =
             %RoomMember{}
             |> RoomMember.changeset(second_changeset)
             |> Repo.insert()

           [member1, member2]
         end) do
      {:ok, members} -> {:ok, members}
      {:error, reason} -> {:error, reason}
    end
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

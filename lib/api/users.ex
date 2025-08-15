defmodule Api.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Api.Repo
  alias Api.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def find_users(name) do
    name = "%" <> name <> "%"
    query = from u in User, where: like(u.name, ^name)
    Repo.all(query)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)
  def get_user(id), do: Repo.get(User, id)

  def get_user_by_name(name) do
    Repo.get_by(User, name: name)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    user_data =
      %User{}
      |> User.register_changeset(attrs)

    Repo.insert(user_data)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user_public_key(user_id, new_public_key) do
    User
    |> where(id: ^user_id)
    |> Repo.update_all(set: [public_key: new_public_key])
  end

  @doc """
  Checks if user exists by name.

  ## Examples

      iex> exists?(name)
      true

      iex> exists?(name)
      false

  """
  def exists?(name) do
    query = from u in User, where: u.name == ^name
    Repo.exists?(query)
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def verify_password(%User{password_hash: hash}, password) when is_binary(password) do
    Argon2.verify_pass(password, hash)
  end
end

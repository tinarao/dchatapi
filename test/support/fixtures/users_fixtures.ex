defmodule Api.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        bio: "some bio",
        name: "some name",
        password_hash: "some password_hash",
        picture_url: "some picture_url",
        public_key: "some public_key"
      })
      |> Api.Users.create_user()

    user
  end
end

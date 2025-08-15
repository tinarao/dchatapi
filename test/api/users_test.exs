defmodule Api.UsersTest do
  use Api.DataCase

  alias Api.Users

  @default_user_attrs %{
    name: "name",
    password: "password",
    public_key: "public_key"
  }

  describe "users" do
    alias Api.Users.User

    import Api.UsersFixtures

    @invalid_attrs %{name: nil, public_key: nil, bio: nil, picture_url: nil, password_hash: nil}

    test "get_user!/1 returns the user with given id" do
      user =
        user_fixture(%{
          name: "name",
          password: "fdsfmdsfksdfdsjkfdskj",
          public_key: "fdsnfjdsdsfjs"
        })

      assert Users.get_user!(user.id).name == user.name
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        name: "some name",
        public_key: "some public_key",
        password: "passwordpassword"
      }

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.public_key == valid_attrs.public_key
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user =
        user_fixture(%{
          name: "name",
          password: "password",
          public_key: "public_key"
        })

      update_attrs = %{
        name: "some updated name",
        public_key: "some updated public_key",
        bio: "some updated bio",
        picture_url: "some updated picture_url"
      }

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.public_key == "some updated public_key"
      assert user.bio == "some updated bio"
      assert user.picture_url == "some updated picture_url"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture(@default_user_attrs)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user.name == Users.get_user!(user.id).name
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture(@default_user_attrs)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture(@default_user_attrs)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end

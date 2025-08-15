defmodule ApiWeb.UserControllerTest do
  use ApiWeb.ConnCase, async: true
  alias Api.UsersFixtures

  @mock_user %{
    name: "some_user_name",
    password: "some_password",
    public_key: "some_key"
  }

  @second_mock_user %{
    name: "some_another_name",
    password: "some_password",
    public_key: "some_key"
  }

  def authorized_conn(conn) do
    user = UsersFixtures.user_fixture(@mock_user)

    login_conn =
      post(conn, ~p"/api/auth/login", %{
        name: user.name,
        password: user.password
      })

    assert login_conn.status == 201
    response = json_response(login_conn, 201)
    token = response["token"]

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> token)

    [conn, user]
  end

  describe "GET /api/users/:name" do
    test "should fail if user not exists", %{conn: conn} do
      [auth_conn, user] = authorized_conn(conn)

      result = get(auth_conn, ~p"/api/users/unexisting")
      assert result.status == 404
    end

    test "should return user if user exists", %{conn: conn} do
      [auth_conn, user] = authorized_conn(conn)

      result = get(auth_conn, ~p"/api/users/#{user.name}")
      assert result.status == 200
    end
  end

  describe "GET /api/users/find/:query" do
    test "should return a list of results", %{conn: conn} do
      [auth_conn, user] = authorized_conn(conn)

      second_user = UsersFixtures.user_fixture(@second_mock_user)

      query =
        second_user.name
        |> String.graphemes()
        |> Enum.at(0)

      result = get(auth_conn, ~p"/api/users/find/#{query}")
      assert result.status == 200

      response = json_response(result, 200)
      users = response["users"] |> assert
      refute Enum.count(users) == 0
    end
  end
end

defmodule Api.AuthControllerTest do
  alias Api.Sessions
  alias Api.UsersFixtures
  use ApiWeb.ConnCase, async: true

  @mock_user %{
    name: "name",
    password: "password",
    public_key: "public_key"
  }

  def authorized_conn(conn) do
    UsersFixtures.user_fixture(@mock_user)
    login_conn = post(conn, ~p"/api/auth/login", @mock_user)
    assert login_conn.status == 201
    response = json_response(login_conn, 201)
    token = response["token"]

    conn
    |> put_req_header("authorization", "Bearer " <> token)
  end

  describe "POST /api/auth/login" do
    test "request with unknown user should fail", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/login", %{name: "unknown", password: "10"})
      assert conn.status == 400
    end

    test "request with valid data should work fine", %{conn: conn} do
      UsersFixtures.user_fixture(@mock_user)
      conn = post(conn, ~p"/api/auth/login", @mock_user)

      assert conn.status == 201
      response = json_response(conn, 201)
      assert Map.has_key?(response, "token")
      token = response["token"]

      assert Sessions.session_exists?(token)
      assert {:ok, session} = Sessions.get_session(token)
      assert session["user_name"] == @mock_user.name
    end
  end

  describe "POST /api/auth/signup" do
    test "request with invalid data should fail", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/signup", %{name: "", password: "1", public_key: ""})
      assert conn.status == 400

      response = json_response(conn, 400)
      assert error = response["error"]
      assert error["password"] |> Enum.at(0) == "пароль слишком короткий"
      assert error["name"] |> Enum.at(0) == "поле не может быть пустым"
    end

    #
    test "request with valid values should and create user", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/signup", @mock_user)
      assert conn.status == 201

      response = json_response(conn, 201)
      assert user = response["user"]
      assert user["id"] |> is_number()
      assert user["name"] == @mock_user.name

      # basically should not return any passwords
      refute user["password"]
      refute user["password_hash"]
    end

    test "should not register user with duplicate name", %{conn: conn} do
      data = %{
        name: "some_username",
        password: "aboba_1488",
        public_key: "some_key"
      }

      conn = post(conn, ~p"/api/auth/signup", data)
      assert conn.status == 201

      conn = post(conn, ~p"/api/auth/signup", data)
      assert conn.status == 400

      response = json_response(conn, 400)
      assert response["error"]
      assert response["error"] == "пользователь уже существует"
    end
  end

  describe "GET /api/auth/verify" do
    test "request without token should fail", %{conn: conn} do
      conn
      |> put_req_header("authorization", "Bearer")

      conn = get(conn, ~p"/api/auth/verify")

      assert conn.status === 401
    end

    test "request with invalid token value should fail", %{conn: conn} do
      conn
      |> put_req_header("authorization", "Bearer undefined")

      conn = get(conn, ~p"/api/auth/verify")

      assert conn.status === 401
    end

    test "request with non-consistent data should fail", %{conn: conn} do
      changeset = %{
        name: "some_username",
        password: "123456_789",
        public_key: "key"
      }

      login_payload = %{
        name: changeset.name,
        password: changeset.password
      }

      UsersFixtures.user_fixture(changeset)
      login_conn = post(conn, ~p"/api/auth/login", login_payload)

      assert login_conn.status == 201
      response = json_response(login_conn, 201)
      assert Map.has_key?(response, "token")
      token = response["token"]

      conn
      |> put_req_header("authorization", "Bearer " <> token)
      |> assign(:device_id, "invalid")

      conn = get(conn, ~p"/api/auth/verify")
      assert conn.status == 401
      response = json_response(conn, 401)
      assert response["error"] == "unauthorized"
    end
  end

  describe "DELETE /api/auth/logout" do
    test "request without token should fail", %{conn: conn} do
      conn = delete(conn, ~p"/api/auth/logout")
      assert conn.status == 401

      response = json_response(conn, 401)
      assert response["error"] == "Некорректный токен"
    end

    test "request with invalid token should fail", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid_token")

      conn = delete(conn, ~p"/api/auth/logout")
      assert conn.status == 401

      response = json_response(conn, 401)
      assert response["error"] == "Некорректный токен"
    end

    test "request with valid token but non-existent session should fail", %{conn: conn} do
      changeset = %{
        name: "some_username",
        password: "123456_789",
        public_key: "some_key"
      }

      UsersFixtures.user_fixture(changeset)

      login_conn =
        post(conn, ~p"/api/auth/login", %{
          name: changeset.name,
          password: changeset.password
        })

      assert login_conn.status == 201
      response = json_response(login_conn, 201)
      token = response["token"]

      Sessions.delete_session(token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)

      conn = delete(conn, ~p"/api/auth/logout")
      assert conn.status == 404

      response = json_response(conn, 404)
      assert response["error"] == "Сессия не найдена"
    end

    test "request with valid token and existing session should work", %{conn: conn} do
      changeset = %{
        name: "some_username",
        password: "123456_789",
        public_key: "some_key"
      }

      UsersFixtures.user_fixture(changeset)

      login_conn =
        post(conn, ~p"/api/auth/login", %{
          name: changeset.name,
          password: changeset.password
        })

      assert login_conn.status == 201
      response = json_response(login_conn, 201)
      assert response["token"]
      token = response["token"]

      assert Sessions.session_exists?(token)

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)

      conn = delete(conn, ~p"/api/auth/logout")
      assert conn.status == 200

      response = json_response(conn, 200)
      assert response["message"] == "ok"

      refute Sessions.session_exists?(token)
    end
  end
end

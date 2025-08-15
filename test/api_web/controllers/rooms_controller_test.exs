defmodule ApiWeb.RoomsControllerTest do
  use ApiWeb.ConnCase
  alias Api.RoomMembersFixtures
  alias Api.RoomsFixtures
  alias Api.Rooms
  alias Api.UsersFixtures

  @mock_user %{
    name: "name",
    password: "aboba_aboba",
    public_key: "some_key"
  }

  @second_mock_user %{
    name: "second_name",
    password: "second_aboba_aboba",
    public_key: "some_key"
  }

  def authorized_conn(conn) do
    user = UsersFixtures.user_fixture(@mock_user)

    login_conn =
      post(conn, ~p"/api/auth/login", %{
        name: @mock_user.name,
        password: @mock_user.password
      })

    assert login_conn.status == 201
    response = json_response(login_conn, 201)
    token = response["token"]

    conn =
      conn
      |> put_req_header("authorization", "Bearer " <> token)

    [user, conn]
  end

  describe "GET /api/rooms/show/:id" do
    test "should return 404 if room with provided id is not exist", %{conn: conn} do
      [_, auth_conn] = authorized_conn(conn)
      conn = get(auth_conn, ~p"/api/rooms/show/999")
      assert conn.status == 404
    end
  end

  describe "GET /api/rooms/my" do
    test "should return list of rooms user participates in", %{conn: conn} do
      [user, auth_conn] = authorized_conn(conn)

      room =
        RoomsFixtures.room_fixture(%{
          name: "some_room_name",
          is_private: true,
          creator_id: user.id
        })

      RoomMembersFixtures.room_member_fixture(%{
        encr_room_key: "some_encr_room_key",
        user_id: user.id,
        room_id: room.id
      })

      result = get(auth_conn, ~p"/api/rooms/my")
      assert result.status == 200

      response = json_response(result, 200)
      rooms = response["rooms"] |> assert
      assert rooms = [room]
    end
  end

  describe "POST /api/rooms" do
    test "should fail if unauthorized", %{conn: conn} do
      contact = UsersFixtures.user_fixture(@second_mock_user)

      conn =
        post(conn, ~p"/api/rooms/", %{
          withName: contact.name,
          isPrivate: true,
          encrRoomKey: "some_key"
        })

      assert conn.status == 401
    end

    test "should successfully create room without room_members", %{conn: conn} do
      contact = UsersFixtures.user_fixture(@second_mock_user)
      [_, auth_conn] = authorized_conn(conn)

      conn =
        post(auth_conn, ~p"/api/rooms/", %{
          withName: contact.name,
          isPrivate: true
        })

      assert conn.status == 201

      response = json_response(conn, 201)
      assert response["room"]
      room = response["room"]

      assert room["id"]
      assert room["name"] == @mock_user.name <> " / " <> @second_mock_user.name

      room = Rooms.get_room(room["id"])
      refute is_nil(room)
    end
  end
end

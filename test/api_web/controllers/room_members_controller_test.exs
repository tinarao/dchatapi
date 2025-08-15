defmodule ApiWeb.RoomMembersControllerTest do
  use ApiWeb.ConnCase
  alias Api.RoomMembers
  alias Api.RoomsFixtures
  alias Api.Rooms
  alias Api.Rooms.Room
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

  describe "POST /api/room_members" do
    test "should fail if room does not exist", %{conn: conn} do
      [auth_conn, user] = authorized_conn(conn)
      second_user = UsersFixtures.user_fixture(@second_mock_user)

      conn =
        post(auth_conn, ~p"/api/room_members", %{
          roomId: 1_400_000,
          userId: second_user.id,
          key: "some_key"
        })

      assert conn.status == 404
    end

    test "should successfully create room_members if data is correct", %{conn: conn} do
      [auth_conn, user] = authorized_conn(conn)
      second_user = UsersFixtures.user_fixture(@second_mock_user)

      room =
        RoomsFixtures.room_fixture(%{
          creator_id: user.id,
          name: "some_room_name",
          is_private: true
        })

      assert room.creator_id == user.id

      conn =
        post(auth_conn, ~p"/api/room_members", %{
          roomId: room.id,
          userId: second_user.id,
          key: "some_key"
        })

      assert conn.status == 201
      response = json_response(conn, 201)
      r_member = response["member"] |> assert

      assert r_member["id"]
      assert r_member["user_id"] == second_user.id
      assert r_member["room_id"] == room.id

      member = RoomMembers.get_room_member(r_member["id"])
      assert member.user_id == r_member["user_id"]
      assert member.room_id == r_member["room_id"]
    end
  end
end

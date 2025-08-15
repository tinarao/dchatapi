defmodule Api.RoomMembersTest do
  use Api.DataCase

  alias Api.RoomMembers

  describe "room_members" do
    alias Api.RoomMembers.RoomMember

    import Api.RoomMembersFixtures

    @invalid_attrs %{encr_room_key: nil}

    test "list_room_members/0 returns all room_members" do
      room_member = room_member_fixture()
      assert RoomMembers.list_room_members() == [room_member]
    end

    test "get_room_member!/1 returns the room_member with given id" do
      room_member = room_member_fixture()
      assert RoomMembers.get_room_member!(room_member.id) == room_member
    end

    test "create_room_member/1 with valid data creates a room_member" do
      valid_attrs = %{encr_room_key: "some encr_room_key"}

      assert {:ok, %RoomMember{} = room_member} = RoomMembers.create_room_member(valid_attrs)
      assert room_member.encr_room_key == "some encr_room_key"
    end

    test "create_room_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RoomMembers.create_room_member(@invalid_attrs)
    end

    test "update_room_member/2 with valid data updates the room_member" do
      room_member = room_member_fixture()
      update_attrs = %{encr_room_key: "some updated encr_room_key"}

      assert {:ok, %RoomMember{} = room_member} =
               RoomMembers.update_room_member(room_member, update_attrs)

      assert room_member.encr_room_key == "some updated encr_room_key"
    end

    test "update_room_member/2 with invalid data returns error changeset" do
      room_member = room_member_fixture()

      assert {:error, %Ecto.Changeset{}} =
               RoomMembers.update_room_member(room_member, @invalid_attrs)

      assert room_member == RoomMembers.get_room_member!(room_member.id)
    end

    test "delete_room_member/1 deletes the room_member" do
      room_member = room_member_fixture()
      assert {:ok, %RoomMember{}} = RoomMembers.delete_room_member(room_member)
      assert_raise Ecto.NoResultsError, fn -> RoomMembers.get_room_member!(room_member.id) end
    end

    test "change_room_member/1 returns a room_member changeset" do
      room_member = room_member_fixture()
      assert %Ecto.Changeset{} = RoomMembers.change_room_member(room_member)
    end
  end
end

defmodule Api.RoomMembersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.RoomMembers` context.
  """

  @doc """
  Generate a room_member.
  """
  def room_member_fixture(attrs \\ %{}) do
    {:ok, room_member} =
      attrs
      |> Enum.into(%{
        ecnr_room_key: "some ecnr_room_key"
      })
      |> Api.RoomMembers.create_room_member()

    room_member
  end
end

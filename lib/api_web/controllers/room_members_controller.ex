defmodule ApiWeb.RoomMembersController do
  alias Api.RoomMembers
  alias Api.Users
  alias Api.Rooms
  use ApiWeb, :controller

  # user_data = %{
  #   id: :integer,
  #   key: :string
  # }

  def create(conn, %{"roomId" => room_id, "userId" => user_id, "key" => key}) do
    current_user = conn.assigns.current_user

    # love this elixir feature
    with %Rooms.Room{} = room <- Rooms.get_room(room_id),
         %Users.User{} = user <- Users.get_user(user_id),
         true <- current_user.id == room.creator_id,
         {:ok, member} <-
           RoomMembers.create_room_member(%{
             encr_room_key: key,
             room_id: room.id,
             user_id: user.id
           }) do
      conn |> put_status(201) |> json(%{message: "ok", member: member})
    else
      nil ->
        conn
        |> put_status(404)
        |> json(%{error: "комната и/или пользователь не найдены"})

      {:error, reason} ->
        IO.inspect(reason)

        conn
        |> put_status(401)
        |> json(%{
          error: "не удалось добавить пользователей в комнату",
          details: Jason.encode(reason)
        })

      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "непредвиденная ошибка сервера"})
    end
  end
end

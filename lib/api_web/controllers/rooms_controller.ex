defmodule ApiWeb.RoomsController do
  use ApiWeb, :controller
  alias Api.Rooms
  alias Api.Users

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with %Rooms.Room{} = room <- Rooms.get_room(id),
         true <- Rooms.can_user_access_this_room?(user.id, room) do
      conn |> put_status(200) |> json(%{room: room})
    else
      nil ->
        conn |> put_status(404) |> json(%{room: "комната не найдена"})
    end
  end

  def get_my_rooms(conn, _) do
    user = conn.assigns.current_user

    rooms = Rooms.get_rooms_user_participates_in(user.id)
    conn |> put_status(200) |> json(%{rooms: rooms})
  end

  def create(conn, %{
        "withName" => with_name,
        "isPrivate" => is_private
      }) do
    user = conn.assigns.current_user

    with false <- user.name == with_name,
         %Users.User{} = contact <- Users.get_user_by_name(with_name),
         {:ok, room} <-
           Rooms.create_room(%{
             creator_id: user.id,
             is_private: is_private,
             name: "#{user.name} / #{contact.name}"
           }) do
      conn
      |> put_status(201)
      |> json(%{
        room: room
      })
    else
      nil ->
        conn |> put_status(401) |> json(%{error: "пользователь " <> with_name <> " не найден"})

      true ->
        conn |> put_status(400) |> json(%{error: "нельзя создать комнату с самим собой"})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: "не удалось создать комнату", description: reason})
    end
  end
end

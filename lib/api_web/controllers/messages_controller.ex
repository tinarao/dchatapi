defmodule ApiWeb.MessagesController do
  alias Api.Messages
  alias Api.Rooms
  use ApiWeb, :controller

  def clear_history(conn, %{"room_id" => room_id}) do
    user = conn.assigns.current_user

    with %Rooms.Room{} = room <- Rooms.get_room(room_id),
         true <- room.creator_id == user.id do
      Messages.delete_all_by_chat(room_id)
      conn |> put_status(200) |> json(%{message: "ok"})
    else
      nil ->
        conn |> put_status(404) |> json(%{error: "комната не найдена"})

      false ->
        conn |> put_status(403) |> json(%{error: "Вы не можете это сделать"})

      _ ->
        conn |> put_status(500) |> json(%{error: "возникла непредвиденная ошибка"})
    end
  end
end

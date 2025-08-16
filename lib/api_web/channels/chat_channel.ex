defmodule ApiWeb.ChatChannel do
  use ApiWeb, :channel
  alias Api.Tokens
  alias Api.Rooms
  alias Api.RoomMembers

  @impl true
  def join("chat_channel:" <> room_id, _payload, socket) do
    user = socket.assigns.user

    case authorized?(user, room_id) do
      :ok -> {:ok, socket}
      :error -> {:error, %{title: "Вы не можете подключиться к этой комнате"}}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat:lobby).
  @impl true
  def handle_in("new_message", %{"msgBase64" => msg_base64, "token" => token}, socket) do
    with {:ok, user} <- Tokens.get_user_from_token(token) do
      payload = %{
        message: msg_base64,
        created_at: DateTime.utc_now(),
        from: user.name
      }

      broadcast(socket, "new_message", payload)
      {:reply, :ok, socket}
    else
      _ ->
        {:error, %{title: "unauthorized"}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(user, room_id) do
    with %Rooms.Room{} = room <- Rooms.get_room(room_id),
         %RoomMembers.RoomMember{} = room_member <- RoomMembers.get_by_ids(user.id, room.id) do
      :ok
    else
      _ ->
        :error
    end
  end
end

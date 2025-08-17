defmodule ApiWeb.ChatChannel do
  use ApiWeb, :channel
  alias Api.Tokens
  alias Api.Rooms
  alias Api.RoomMembers
  alias Api.Messages

  @impl true
  def join("chat_channel:" <> room_id, _payload, socket) do
    user = socket.assigns.user

    messages = Messages.get_messages_by_room(room_id)
    IO.inspect(messages, label: "messages")

    case authorized?(user, room_id) do
      :ok -> {:ok, %{messages: messages}, socket}
      :error -> {:error, %{title: "Вы не можете подключиться к этой комнате"}}
    end
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat:lobby).
  @impl true
  def handle_in("new_message", %{"cipherText" => cipher_text}, socket) do
    user = socket.assigns.user

    "chat_channel:" <> room_id = socket.topic

    save_message_async(cipher_text, room_id, user.id)

    payload = %{
      id: :rand.uniform(),
      cipher_text: cipher_text,
      user: user,
      inserted_at: DateTime.utc_now()
    }

    broadcast(socket, "new_message", payload)
    {:reply, :ok, socket}
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

  defp save_message_async(cipher_text, room_id, user_id) do
    Task.start(fn ->
      Messages.create_message(%{
        cipher_text: cipher_text,
        room_id: room_id,
        user_id: user_id
      })
      |> IO.inspect(label: "saved message")
    end)
  end
end

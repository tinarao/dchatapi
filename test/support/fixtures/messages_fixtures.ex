defmodule Api.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Api.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        cipher_text: "some cipher_text"
      })
      |> Api.Messages.create_message()

    message
  end
end

defmodule Api.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :cipher_text, :binary
    field :room_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:cipher_text])
    |> validate_required([:cipher_text])
  end
end

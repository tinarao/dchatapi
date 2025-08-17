defmodule Api.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Jason.Encoder,
    only: [:id, :cipher_text, :room_id, :user, :inserted_at, :updated_at]
  }

  schema "messages" do
    field :cipher_text, :binary
    field :room_id, :id
    belongs_to :user, Api.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:cipher_text, :room_id, :user_id])
    |> validate_required([:cipher_text])
  end
end

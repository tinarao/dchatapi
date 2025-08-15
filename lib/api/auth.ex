defmodule Api.Auth do
  alias Api.Errors
  alias Api.Tokens
  alias Api.Users
  alias Api.Sessions

  def login(name, password, device_id) do
    with %Users.User{} = user <- Users.get_user_by_name(name),
         true <- Users.verify_password(user, password),
         token <-
           Tokens.encrypt(%{
             user_id: user.id,
             device_id: device_id
           }),
         :ok <- Sessions.create_session(token, user.name, device_id) do
      {:ok, token |> to_string()}
    else
      nil ->
        {:error, "пользователь не найден"}

      {:error, reason} ->
        IO.inspect(reason, label: "login failure at 22")
        {:error, "некорректные авторизационные данные"}
    end
  end

  def signup(name, password, public_key) do
    changeset = %{
      name: name,
      password: password,
      public_key: public_key
    }

    with false <- Users.exists?(name),
         {:ok, user} <- Users.create_user(changeset) do
      {:ok, user}
    else
      true ->
        {:error, "пользователь уже существует"}

      {:error, reason} ->
        {:error, Ecto.Changeset.traverse_errors(reason, &Errors.translate_error/1)}
    end
  end

  def generate_device_id(user_agent, remote_ip) do
    data =
      %{
        user_agent: user_agent,
        ip_address: remote_ip
      }
      |> Jason.encode!()

    :crypto.hash(:sha256, data)
    |> Base.encode64()
  end
end

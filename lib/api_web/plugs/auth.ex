defmodule ApiWeb.Plugs.Protected do
  import Plug.Conn
  alias ApiWeb.Auth
  alias Api.Tokens
  alias Api.Sessions
  alias Api.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    try do
      with {:ok, token} <- Auth.extract_token(conn),
           {:ok, data} <- Tokens.decrypt(token),
           {:ok, session} <- Sessions.get_session(token),
           %Users.User{} = user <- Users.get_user_by_name(session["user_name"]) do
        current_device_id = conn.assigns.device_id

        if user.id != data["user_id"] do
          raise "Некорректные данные сессии"
        end

        if user.name != session["user_name"] do
          raise "Некорректные данные сессии"
        end

        if current_device_id != data["device_id"] or data["device_id"] != session["device_id"] do
          raise "Некорректные данные сессии"
        end

        assign(conn, :current_user, user)
      else
        _ ->
          conn
          |> put_resp_content_type("application/json")
          |> send_resp(401, Jason.encode!(%{error: "Вы не авторизованы"}))
          |> halt()
      end
    rescue
      e ->
        IO.inspect(e)

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "Вы не авторизованы"}))
        |> halt()
    end
  end
end

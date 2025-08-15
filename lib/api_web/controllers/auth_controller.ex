defmodule ApiWeb.AuthController do
  use ApiWeb, :controller
  alias Api.Auth
  alias Api.Tokens
  alias Api.Users
  alias Api.Sessions

  def login(conn, %{"name" => name, "password" => password}) do
    device_id = conn.assigns.device_id

    case Auth.login(name, password, device_id) do
      {:ok, token} -> conn |> put_status(201) |> json(%{token: token})
      {:error, reason} -> conn |> put_status(400) |> json(%{error: reason})
    end
  end

  def login(conn, _params) do
    conn |> put_status(400) |> json(%{error: "данные отсутствуют или некорректны"})
  end

  def signup(conn, %{"name" => name, "password" => password, "public_key" => public_key}) do
    case Auth.signup(name, password, public_key) do
      {:ok, user} ->
        conn |> put_status(201) |> json(%{user: user})

      {:error, reason} ->
        conn |> put_status(400) |> json(%{error: reason})
    end
  end

  def signup(conn, _params) do
    conn |> put_status(400) |> json(%{error: "данные отсутствуют или некорректны"})
  end

  def verify_session(conn, _params) do
    try do
      with {:ok, token} <- ApiWeb.Auth.extract_token(conn),
           {:ok, data} <- Tokens.decrypt(token),
           {:ok, session} <- Sessions.get_session(token),
           user <- Users.get_user_by_name(session["user_name"]) do
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

        conn
        |> put_status(200)
        |> json(%{user: user})
      else
        _ ->
          conn
          |> put_status(401)
          |> json(%{
            error: "unauthorized"
          })
      end
    rescue
      # check this thing
      # todo tests
      e -> conn |> put_status(403) |> json(%{error: e})
    end
  end

  def logout(conn, _) do
    with {:ok, token} <- ApiWeb.Auth.extract_token(conn),
         {:ok, _data} <- Tokens.decrypt(token),
         {:ok, _session} <- Sessions.get_session(token),
         :ok <- Sessions.delete_session(token) do
      conn |> put_status(200) |> json(%{message: "ok"})
    else
      {:error, "missing token"} ->
        conn |> put_status(401) |> json(%{error: "Некорректный токен"})

      {:error, "invalid token format"} ->
        conn |> put_status(401) |> json(%{error: "Некорректный токен"})

      {:error, "corrupted token"} ->
        conn |> put_status(401) |> json(%{error: "Некорректный токен"})

      {:error, :session_not_found} ->
        conn |> put_status(404) |> json(%{error: "Сессия не найдена"})

      {:error, reason} ->
        conn
        |> put_status(500)
        |> json(%{error: "Ошибка при удалении сессии: #{inspect(reason)}"})

      _ ->
        conn |> put_status(401) |> json(%{error: "Некорректный токен"})
    end
  end
end

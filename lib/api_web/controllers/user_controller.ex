defmodule ApiWeb.UsersController do
  use ApiWeb, :controller
  alias Api.Users

  def show(conn, %{"name" => name}) do
    case Users.get_user_by_name(name) do
      nil ->
        conn
        |> put_status(404)
        |> json(%{
          error: "not found"
        })

      user ->
        conn |> put_status(200) |> json(%{user: user})
    end
  end

  def find_user(conn, %{"query" => query}) do
    users = Users.find_users(query)
    conn |> put_status(200) |> json(%{users: users})
  end
end

defmodule ApiWeb.Auth do
  use ApiWeb, :controller

  @doc """
  Extracts token from request headers.
  Accepts connection.
  Returns {:error, reason} or {:ok, token}
  """
  def extract_token(conn) do
    case conn
         |> get_req_header("authorization")
         |> Enum.at(0) do
      nil ->
        {:error, "missing token"}

      "Bearer " <> token ->
        {:ok, token}

      _ ->
        {:error, "invalid token format"}
    end
  end

  def extract_user_agent(conn) do
    conn
    |> get_req_header("user-agent")
    |> Enum.at(0)
  end

  def extract_ip(conn) do
    conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
  end
end

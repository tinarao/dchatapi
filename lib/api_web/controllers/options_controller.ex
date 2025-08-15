defmodule ApiWeb.OptionsController do
  use ApiWeb, :controller

  def options(conn, _opts) do
    conn |> send_resp(200, "")
  end
end

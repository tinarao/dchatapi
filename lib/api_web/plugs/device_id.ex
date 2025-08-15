defmodule ApiWeb.Plugs.DeviceID do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    remote_ip = ApiWeb.Auth.extract_ip(conn)
    user_agent = ApiWeb.Auth.extract_user_agent(conn)
    device_id = Api.Auth.generate_device_id(user_agent, remote_ip)

    assign(conn, :device_id, device_id)
  end
end

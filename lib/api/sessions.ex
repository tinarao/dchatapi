defmodule Api.Sessions do
  # hour
  @session_ttl 3600 * 24 * 30 * 4

  def create_session(session_key, user_name, device_id) do
    session_data = %{
      user_name: user_name,
      device_id: device_id,
      created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      last_activity: DateTime.utc_now() |> DateTime.to_iso8601()
    }

    Api.Redis.set_session(session_key, session_data, @session_ttl)
  end

  def get_session(session_key) do
    case Api.Redis.get_session(session_key) do
      nil -> {:error, :session_not_found}
      session_data -> {:ok, session_data}
    end
  end

  def session_exists?(session_key) do
    Api.Redis.session_exists?(session_key)
  end

  def update_activity(session_key) do
    case get_session(session_key) do
      {:ok, session_data} ->
        updated_data =
          Map.put(session_data, :last_activity, DateTime.utc_now() |> DateTime.to_iso8601())

        Api.Redis.set_session(session_key, updated_data, @session_ttl)

      {:error, _} ->
        {:error, :session_not_found}
    end
  end

  def delete_session(session_key) do
    Api.Redis.delete_session(session_key)
  end

  def get_user_name(session_key) do
    case get_session(session_key) do
      {:ok, session_data} -> {:ok, session_data.user_name}
      {:error, reason} -> {:error, reason}
    end
  end

  def get_user_data(user_id) do
    case get_session(user_id) do
      {:ok, session_data} -> {:ok, session_data.user_data}
      {:error, reason} -> {:error, reason}
    end
  end
end

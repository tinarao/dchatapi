defmodule Api.Redis do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    redis_url = Application.get_env(:api, :redis)[:url] || "redis://localhost:6379"
    {:ok, conn} = Redix.start_link(redis_url)
    Logger.info("Redis connected")
    {:ok, conn}
  end

  def set_session(session_key, session_data, ttl \\ 3600) do
    key = "session:#{session_key}"
    GenServer.call(__MODULE__, {:set_session, key, session_data, ttl})
  end

  def get_session(session_key) do
    key = "session:#{session_key}"
    GenServer.call(__MODULE__, {:get_session, key})
  end

  def delete_session(session_key) do
    key = "session:#{session_key}"
    GenServer.call(__MODULE__, {:delete_session, key})
  end

  def session_exists?(session_key) do
    key = "session:#{session_key}"
    GenServer.call(__MODULE__, {:session_exists?, key})
  end

  @impl true
  def handle_call({:set_session, key, session_data, ttl}, _from, conn) do
    case Redix.command(conn, ["SETEX", key, ttl, Jason.encode!(session_data)]) do
      {:ok, "OK"} -> {:reply, :ok, conn}
      {:error, reason} -> {:reply, {:error, reason}, conn}
    end
  end

  @impl true
  def handle_call({:get_session, key}, _from, conn) do
    case Redix.command(conn, ["GET", key]) do
      {:ok, nil} ->
        {:reply, nil, conn}

      {:ok, data} ->
        case Jason.decode(data) do
          {:ok, session_data} -> {:reply, session_data, conn}
          {:error, _} -> {:reply, nil, conn}
        end

      {:error, reason} ->
        {:reply, {:error, reason}, conn}
    end
  end

  @impl true
  def handle_call({:delete_session, key}, _from, conn) do
    case Redix.command(conn, ["DEL", key]) do
      {:ok, _} -> {:reply, :ok, conn}
      {:error, reason} -> {:reply, {:error, reason}, conn}
    end
  end

  @impl true
  def handle_call({:session_exists?, key}, _from, conn) do
    case Redix.command(conn, ["EXISTS", key]) do
      {:ok, 1} -> {:reply, true, conn}
      {:ok, 0} -> {:reply, false, conn}
      {:error, reason} -> {:reply, {:error, reason}, conn}
    end
  end
end

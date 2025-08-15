defmodule Api.RedisCase do
  use ExUnit.CaseTemplate

  setup do
    # Ensure Redis is started
    Application.ensure_all_started(:redis_client)

    # Start the Redis process
    {:ok, _pid} = Api.Redis.start_link([])

    :ok
  end
end

defmodule Api.SessionsTest do
  use Api.DataCase
  alias Api.Sessions

  @user_name "petr"
  @device_id "zhiguli"
  @mock_token "rand_session_key"

  describe "sessions" do
    test "create_session creates a session" do
      assert :ok = Sessions.create_session(@mock_token, @user_name, @device_id)
      assert Sessions.session_exists?(@mock_token)
    end

    test "get_session returns session data" do
      #
      Sessions.create_session(@mock_token, @user_name, @device_id)

      case Sessions.get_session(@mock_token) do
        {:ok, session_data} ->
          assert session_data["device_id"] == @device_id
          assert session_data["user_name"] == @user_name
          assert session_data["created_at"]
          assert session_data["last_activity"]

        {:error, reason} ->
          flunk("Failed to get session: #{reason}")
      end
    end

    test "delete_session removes session" do
      Sessions.create_session(@mock_token, @user_name, @device_id)
      assert Sessions.session_exists?(@mock_token)

      Sessions.delete_session(@mock_token)
      refute Sessions.session_exists?(@mock_token)
    end

    test "session_exists? returns false for non-existent session" do
      refute Sessions.session_exists?(999)
    end
  end
end

defmodule Api.TokensTest do
  use Api.DataCase
  alias Api.Tokens

  @user_id 1
  @device_id "pringles_original_YEEEEEEESSS"

  @payload %{
    user_id: @user_id,
    device_id: @device_id
  }

  describe "tokens" do
    test "encrypt functions generates a binary token" do
      token = Tokens.encrypt(@payload)
      assert token |> is_binary()
    end

    test "decrypt can work on tokens generated via encrypt/1" do
      token = Tokens.encrypt(@payload)
      result = Tokens.decrypt(token)

      assert {:ok, decr} = result
      assert decr["user_id"] == @payload.user_id
      assert decr["device_id"] == @payload.device_id
    end
  end
end

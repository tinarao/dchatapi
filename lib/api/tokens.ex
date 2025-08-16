defmodule Api.Tokens do
  @encryption_key Application.compile_env!(:api, __MODULE__)[:encryption_key]

  alias Api.Users
  alias Api.Sessions

  def secret_key do
    case @encryption_key do
      {:system, _app, value} -> value
      value when is_binary(value) -> value
    end
  end

  @aad ""
  @tag_length 16
  @iv_length 12

  def encrypt(data) when is_map(data) do
    json = Jason.encode!(data)
    iv = :crypto.strong_rand_bytes(@iv_length)
    key = :crypto.hash(:sha256, secret_key())

    {ciphertext, tag} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, json, @aad, @tag_length, true)

    (iv <> tag <> ciphertext)
    |> Base.encode64()
  end

  def encrypt(data) do
    key = :crypto.hash(:sha256, "#{secret_key()}#{data}")
    Base.encode64(key)
  end

  def decrypt(token) do
    with {:ok, bin} <- Base.decode64(token),
         <<iv::binary-size(@iv_length), tag::binary-size(@tag_length), ciphertext::binary>> <-
           bin,
         key = :crypto.hash(:sha256, secret_key()),
         {:ok, plaintext} <- decrypt_aead(ciphertext, key, iv, tag),
         {:ok, data} <- Jason.decode(plaintext) do
      {:ok, data}
    else
      _error ->
        {:error, "corrupted token"}
    end
  end

  def get_user_from_token(token) do
    with {:ok, _data} <- decrypt(token),
         {:ok, session} <- Sessions.get_session(token),
         user <- Users.get_user_by_name(session["user_name"]) do
      {:ok, user}
    else
      _ ->
        {:error, "пользователь не найден и/или токен невалиден"}
    end
  end

  defp decrypt_aead(ciphertext, key, iv, tag) do
    try do
      plaintext =
        :crypto.crypto_one_time_aead(:aes_256_gcm, key, iv, ciphertext, @aad, tag, false)

      {:ok, plaintext}
    rescue
      _ -> {:error, :invalid}
    end
  end
end

defmodule Api.Errors do
  def translate_error({msg, opts}) do
    field =
      case opts[:field] do
        nil -> "данные"
        field -> Phoenix.Naming.humanize(field)
      end

    case {msg, opts} do
      {"can't be blank", _} ->
        "поле не может быть пустым"

      {"has invalid format", _} ->
        "Неправильный формат #{field}"

      {"must be greater than %{number}", number: n} ->
        "#{field} должен быть больше #{n}"

      {"password is too short", _} ->
        "пароль слишком короткий"

      _ ->
        msg
        |> String.replace("%{count}", to_string(opts[:count] || ""))
        |> String.replace("%{field}", field)
    end
  end
end

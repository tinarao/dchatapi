# дич.ат - сервер

<p align="center">
    <img src="https://skillicons.dev/icons?i=elixir" />
</p>

## Серверная часть дич.ат

## Особенности системы

### Отказоустойчивость

- Распределенная архитектура на базе Elixir/OTP
- Автоматическое восстановление после сбоев
- Горизонтальное масштабирование

### Безопасность

- Сквозное шифрование сообщений
- Защищенное хранение данных
- Безопасная аутентификация пользователей

### Комнаты чата

- Приватные комнаты с ограниченным доступом

# Запуск

### Docker Compose

Проект поставляется с настроенным Docker Compose для быстрого развертывания:

```yaml
version: "3.8"
services:
  app:
    build: .
    ports:
      - "4000:4000"
    environment:
      - DATABASE_URL=postgres://postgres:postgres@db:5432/dchat
    depends_on:
      - db

  db:
    image: postgres:14-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=dchat
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## Запуск проекта

### Локальная разработка

```bash
# Установка зависимостей
mix deps.get

# Настройка базы данных
mix ecto.setup

# Запуск сервера
mix phx.server
```

### Запуск через Docker Compose

```bash
# Сборка и запуск контейнеров
docker-compose up -d

# Просмотр логов
docker-compose logs -f

# Остановка
docker-compose down
```

Сервер будет доступен по адресу `http://localhost:4000`

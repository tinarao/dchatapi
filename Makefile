start: docker run

docker:
	docker compose up -d

run:
	@export $$(cat .env | xargs) && mix phx.server

migrate:
	@export $$(cat .env | xargs) && mix ecto.migrate

reset: 
	@export $$(cat .env | xargs) && mix ecto.reset

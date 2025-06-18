COMPOSE_FILE = ./srcs/docker-compose.yml

all:
	@docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down -v

re: clean all

.PHONY: all down clean re

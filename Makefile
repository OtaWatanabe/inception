COMPOSE_FILE = ./srcs/docker-compose.yml

all:
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down --rmi all

fclean:
	docker compose -f $(COMPOSE_FILE) down -v --rmi all

re: fclean all

.PHONY: all down fclean re

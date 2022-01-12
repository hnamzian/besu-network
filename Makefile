up:
	@./scripts/init_besu_nodes.sh
	@./scripts/init_tessera_nodes.sh
	@docker-compose up -d
	@./scripts/generate_connection_profile.sh

down:
	@docker-compose down -v
	sudo rm -rf logs
	rm -rf ./config/nodes
	rm ./config/besu/IBFTgenesis.json ./config/besu/static-nodes.json ./config/besu/permissions_config.toml
	rm -rf ./scripts/connection_profiles
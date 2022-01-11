up:
	@./init_besu_nodes.sh
	@./init_tessera_nodes.sh
	@docker-compose up -d

down:
	@docker-compose down -v
	sudo rm -rf logs
	rm -rf ./config/nodes
	rm ./config/besu/IBFTgenesis.json ./config/besu/static-nodes.json ./config/besu/permissions_config.toml
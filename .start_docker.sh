docker stop $(docker ps -q)
# docker rm $(docker ps -aq)
docker network prune -f

docker network create traefik_network || true

cd /home/leonj/Documents/infra/traefik_docker && docker-compose up -d
cd ../nginx_docker && docker-compose up -d
cd ../code-server_docker && docker-compose up -d
cd ../portainer_docker && docker-compose up -d
cd ../guacamole_docker && docker-compose up -d
cd ../monitoring_docker && docker-compose up -d

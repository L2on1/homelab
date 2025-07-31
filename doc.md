```
docker network create traefik_network || true

cd /home/leonj/Documents/infra/traefik_docker && docker-compose up -d
cd ../caddy_docker && docker-compose up -d
```

Commande pour allumer les docker mis de coté pour l'instant
```
cd ../wetty_docker && docker-compose up -d
cd ../code-server_docker && docker-compose up -d
cd ../portainer_docker && docker-compose up -d
cd ../guacamole_docker && docker-compose up -d
```

Commande pour eteindre tous les dockers
```
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker network prune -f
```

docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker network prune -f

docker network create traefik_network || true

cd /home/leonj/Documents/infra/traefik_docker && docker-compose up -d
cd ../code-server_docker && docker-compose up -d
cd ../portainer_docker && docker-compose up -d
cd ../nginx_docker && docker-compose up -d


8084 : code-server
8083 : caddy-simple-site
8085 : traefik

sous doamine de haribon

ant       : code
bee       : portainer
cat       : test
chouca    : grafana
craw      : traefik
frog      : guacamole

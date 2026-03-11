#!/bin/bash
set -euo pipefail

# docker stop $(docker ps -q)
# # docker rm $(docker ps -aq)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
log() { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"; }
ok()  { echo -e "${GREEN}[OK]${NC} $1" ; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1";  }
err() { echo -e "${RED}[ERR]${NC} $1"  exit 1; }

log "=== Arrêt propre des services Docker ==="

INFRA_DIRS=(
  "/home/leonj/Documents/infra"
)

for INFRA in "${INFRA_DIRS[@]}"; do
  if [[ -d "$INFRA" ]]; then
    for STACK_DIR in "$INFRA"/*/; do
      COMPOSE_FILE=""
      [[ -f "${STACK_DIR}docker-compose.yml" ]] && COMPOSE_FILE="${STACK_DIR}docker-compose.yml"
      [[ -f "${STACK_DIR}compose.yaml" ]]        && COMPOSE_FILE="${STACK_DIR}compose.yaml"

      if [[ -n "$COMPOSE_FILE" ]]; then
        STACK_NAME=$(basename "$STACK_DIR")
        log "  Arrêt : $STACK_NAME"
        (cd "$STACK_DIR" && docker compose down) \
          && ok "  $STACK_NAME arrêté" \
          || warn "  $STACK_NAME — arrêt échoué (ignoré)"
      fi
    done
  fi
done

# docker network prune -f

# docker network create traefik_network || true

# cd /home/leonj/Documents/infra/traefik_docker && docker compose up -d
# cd ../nginx_docker && docker compose up -d
# cd ../code-server_docker && docker compose up -d
# cd ../portainer_docker && docker compose up -d
# cd ../guacamole_docker && docker compose up -d
# cd ../monitoring_docker && docker compose up -d
# cd ../dockge_docker && docker compose up -d
# cd ../uptime-kuma_docker && docker compose up -d
# cd ../memos_docker && docker compose up -d
# cd ../wordpress_4_docker && docker compose up -d

log "=== Redémarrage des services Docker ==="

RESTART_ORDER=(
  "traefik_docker"
  "portainer_docker"
  "dockge_docker"
  "nginx_docker"
#   "wordpress_1_docker"
#   "wordpress_2_docker"
#   "wordpress_3_docker"
  "wordpress_4_docker"
  "memos_docker"
  "monitoring_docker"
  "uptime-kuma_docker"
#   "trilium_note"
  "guacamole_docker"
  "code-server_docker"
)

for STACK in "${RESTART_ORDER[@]}"; do
  STACK_DIR="/home/leonj/Documents/infra/${STACK}"
  COMPOSE_FILE=""
  [[ -f "${STACK_DIR}/docker-compose.yml" ]] && COMPOSE_FILE="${STACK_DIR}/docker-compose.yml"
  [[ -f "${STACK_DIR}/compose.yaml" ]]        && COMPOSE_FILE="${STACK_DIR}/compose.yaml"

  if [[ -n "$COMPOSE_FILE" ]]; then
    log "  Démarrage : $STACK"
    (cd "$STACK_DIR" && docker compose up -d) \
      && ok "  $STACK démarré" \
      || warn "  $STACK — démarrage échoué"
    sleep 2  # petite pause entre chaque service
  fi
done

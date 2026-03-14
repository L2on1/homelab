#!/bin/bash
# ============================================================
#  backup_homelab.sh — Sauvegarde complète du homelab
#  Destination : /mnt/Nas/Save/home_server_save/save/
#  Archive     : .tar.xz (compression maximale)
# ============================================================

set -euo pipefail

# ---------- CONFIG ------------------------------------------
DEST="/mnt/Nas/Save/home_server_save/save_2026_03_08"
DATE=$(date +%Y%m%d_%H%M%S)
HOSTNAME=$(hostname)
ARCHIVE_NAME="backup_${HOSTNAME}_${DATE}.tar.xz"
FULL_PATH="${DEST}/${ARCHIVE_NAME}"
LOG_FILE="${DEST}/backup_${DATE}.log"

# Dossiers à sauvegarder
SOURCES=(
  "/home"
  "/var/lib"
)

# Dossiers à exclure (trop volumineux / inutiles)
EXCLUDES=(
  "--exclude=/var/lib/snapd"
  "--exclude=/var/lib/apt"
  "--exclude=/var/lib/dpkg"
  "--exclude=/var/lib/systemd"
  "--exclude=/home/*/.cache"
  "--exclude=/home/*/.local/share/Trash"
  "--exclude=/home/*/.thumbnails"
)

# ---------- COULEURS ----------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---------- FONCTIONS ---------------------------------------
log() { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"; }
ok()  { echo -e "${GREEN}[OK]${NC} $1" | tee -a "$LOG_FILE"; }
warn(){ echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
err() { echo -e "${RED}[ERR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }

# ---------- VÉRIFICATIONS -----------------------------------
log "=== Démarrage de la sauvegarde ==="

# Vérifie les droits root
if [[ $EUID -ne 0 ]]; then
  err "Ce script doit être exécuté en root : sudo ./backup_homelab.sh"
fi

# Vérifie que la destination NAS est montée
if ! mountpoint -q /mnt/Nas 2>/dev/null && ! [ -d "$DEST" ]; then
  err "Le NAS n'est pas monté sur /mnt/Nas — vérifie la connexion réseau/NFS/SMB"
fi

# Crée le dossier de destination si nécessaire
mkdir -p "$DEST"
ok "Destination : $FULL_PATH"

# Espace disque disponible sur le NAS
SPACE=$(df -BG "$DEST" | awk 'NR==2 {print $4}' | tr -d 'G')
log "Espace disponible sur le NAS : ${SPACE}G"
if [[ "$SPACE" -lt 10 ]]; then
  warn "Moins de 10G disponibles sur le NAS — continue quand même..."
fi

# ---------- DUMP SQL WORDPRESS ------------------------------
log "=== Dump des bases de données WordPress ==="

DUMP_DIR="/tmp/wp_dumps_${DATE}"
mkdir -p "$DUMP_DIR"

# Cherche tous les containers MySQL/MariaDB en cours
MYSQL_CONTAINERS=$(docker ps --format '{{.Names}}' | grep -iE 'mysql|mariadb|db' || true)

if [[ -z "$MYSQL_CONTAINERS" ]]; then
  warn "Aucun container MySQL/MariaDB détecté — pas de dump SQL"
else
  for CONTAINER in $MYSQL_CONTAINERS; do
    log "Dump du container : $CONTAINER"
    DUMP_FILE="${DUMP_DIR}/${CONTAINER}_${DATE}.sql"

    # Tente le dump avec les variables d'env du container
    DB_ROOT_PASS=$(docker inspect "$CONTAINER" \
      --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null \
      | grep -E 'MYSQL_ROOT_PASSWORD|MARIADB_ROOT_PASSWORD' \
      | cut -d= -f2 | head -1 || echo "")

    if [[ -n "$DB_ROOT_PASS" ]]; then
      docker exec "$CONTAINER" \
        mysqldump -u root -p"${DB_ROOT_PASS}" --all-databases \
        > "$DUMP_FILE" 2>>"$LOG_FILE" \
        && ok "Dump OK → $DUMP_FILE" \
        || warn "Dump échoué pour $CONTAINER"
    else
      warn "Pas de mot de passe root trouvé pour $CONTAINER — dump ignoré"
    fi
  done
fi

# ---------- ARRÊT DES SERVICES DOCKER -----------------------
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
        (cd "$STACK_DIR" && docker compose down 2>>"$LOG_FILE") \
          && ok "  $STACK_NAME arrêté" \
          || warn "  $STACK_NAME — arrêt échoué (ignoré)"
      fi
    done
  fi
done

# ---------- CRÉATION DE L'ARCHIVE ---------------------------
log "=== Création de l'archive tar.xz ==="
log "  Sources : ${SOURCES[*]}"
log "  Archive : $FULL_PATH"
log "  (Compression XZ — peut prendre plusieurs minutes...)"

tar \
  --create \
  --xz \
  --preserve-permissions \
  --numeric-owner \
  "${EXCLUDES[@]}" \
  --file="$FULL_PATH" \
  --checkpoint=1000 \
  --checkpoint-action=dot \
  "${SOURCES[@]}" \
  "$DUMP_DIR" \
  2>>"$LOG_FILE"

echo "" # saut de ligne après les points de progression
ok "Archive créée avec succès !"

# ---------- VÉRIFICATION DE L'ARCHIVE -----------------------
log "=== Vérification de l'intégrité ==="
tar --list --file="$FULL_PATH" > /dev/null 2>&1 \
  && ok "Intégrité de l'archive vérifiée" \
  || err "L'archive semble corrompue !"

# Taille finale
SIZE=$(du -sh "$FULL_PATH" | cut -f1)
ok "Taille de l'archive : $SIZE"

# ---------- NETTOYAGE ---------------------------------------
log "=== Nettoyage des fichiers temporaires ==="
rm -rf "$DUMP_DIR"
ok "Dumps SQL temporaires supprimés"

# ---------- REDÉMARRAGE DES SERVICES ------------------------
log "=== Redémarrage des services Docker ==="

RESTART_ORDER=(
  "traefik_docker"
  # "portainer_docker"
  "dockge_docker"
  "nginx_docker"
  # "wordpress_1_docker"
  # "wordpress_2_docker"
  # "wordpress_3_docker"
  "wordpress_4_docker"
  "memos_docker"
  "monitoring_docker"
  # "uptime-kuma_docker"
  # "trilium_note"
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
    (cd "$STACK_DIR" && docker compose up -d 2>>"$LOG_FILE") \
      && ok "  $STACK démarré" \
      || warn "  $STACK — démarrage échoué"
    sleep 2  # petite pause entre chaque service
  fi
done

# ---------- RÉSUMÉ ------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  SAUVEGARDE TERMINÉE${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "  Archive  : ${BLUE}${FULL_PATH}${NC}"
echo -e "  Taille   : ${BLUE}${SIZE}${NC}"
echo -e "  Log      : ${BLUE}${LOG_FILE}${NC}"
echo -e "  Date     : ${BLUE}$(date)${NC}"
echo -e "${GREEN}============================================${NC}"
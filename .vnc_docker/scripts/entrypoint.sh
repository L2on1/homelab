#!/bin/bash
set -e

PASSFILE="/tmp/vncpasswd"

# Crée un mot de passe VNC temporaire (modifiable)
echo "$VNC_PASSWORD" | vncpasswd -f > "$PASSFILE"
chmod 600 "$PASSFILE"

# Lance x0vncserver sur la session locale
exec x0vncserver -display :0 \
     -rfbauth "$PASSFILE" \
     -rfbport 5901 \
     -noxdamage \
     -alwaysshared \
     -log *:stderr:100

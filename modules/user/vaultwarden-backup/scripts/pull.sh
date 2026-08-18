mkdir -p "$HOME/vaultwarden-backups"
rsync -az --exclude '/icon_cache/' --exclude '/tmp/' vps:/var/backup/vaultwarden/ "$HOME/vaultwarden-backups/"

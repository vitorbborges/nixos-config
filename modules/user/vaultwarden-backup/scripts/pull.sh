mkdir -p "$HOME/vaultwarden-backups"
rsync -az vps:/var/backup/vaultwarden/ "$HOME/vaultwarden-backups/"

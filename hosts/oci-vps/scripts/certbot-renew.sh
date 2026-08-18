compose="docker-compose -f /etc/adguardhome/docker-compose.yml"
$compose stop || true
systemctl stop vaultwarden.service || true
certbot certonly \
  --standalone \
  --non-interactive \
  --agree-tos \
  --expand \
  --email vitorbborges31@gmail.com \
  -d dns.vitorbborges.space \
  -d vault.vitorbborges.space \
  && {
    cp /etc/letsencrypt/live/dns.vitorbborges.space/fullchain.pem /var/lib/adguardhome/conf/fullchain.pem
    cp /etc/letsencrypt/live/dns.vitorbborges.space/privkey.pem   /var/lib/adguardhome/conf/privkey.pem
    chmod 640 /var/lib/adguardhome/conf/fullchain.pem /var/lib/adguardhome/conf/privkey.pem

    cp /etc/letsencrypt/live/dns.vitorbborges.space/fullchain.pem /var/lib/vaultwarden-certs/fullchain.pem
    cp /etc/letsencrypt/live/dns.vitorbborges.space/privkey.pem   /var/lib/vaultwarden-certs/privkey.pem
    chmod 640 /var/lib/vaultwarden-certs/fullchain.pem /var/lib/vaultwarden-certs/privkey.pem
    chown vaultwarden:vaultwarden /var/lib/vaultwarden-certs/fullchain.pem /var/lib/vaultwarden-certs/privkey.pem
  }
$compose start
systemctl start vaultwarden.service || true

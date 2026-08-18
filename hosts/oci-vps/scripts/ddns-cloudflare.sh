set -uo pipefail
api="https://api.cloudflare.com/client/v4"
token=$(cat "@tokenPath@")
auth=(-H "Authorization: Bearer $token" -H "Content-Type: application/json")

current_ip=$(curl -s https://api.ipify.org)
if [ -z "$current_ip" ]; then
  echo "could not determine current public IP" >&2
  exit 1
fi

zone_id=$(curl -s "${auth[@]}" "$api/zones?name=@zoneName@" | jq -r '.result[0].id')
if [ -z "$zone_id" ] || [ "$zone_id" = "null" ]; then
  echo "could not resolve zone id for @zoneName@" >&2
  exit 1
fi

for name in @records@; do
  record=$(curl -s "${auth[@]}" "$api/zones/$zone_id/dns_records?type=A&name=$name")
  record_id=$(echo "$record" | jq -r '.result[0].id')
  record_ip=$(echo "$record" | jq -r '.result[0].content')
  record_ttl=$(echo "$record" | jq -r '.result[0].ttl')

  if [ -z "$record_id" ] || [ "$record_id" = "null" ]; then
    echo "no A record found for $name, skipping" >&2
    continue
  fi

  if [ "$record_ip" != "$current_ip" ] || [ "$record_ttl" != "300" ]; then
    curl -s -X PATCH "${auth[@]}" "$api/zones/$zone_id/dns_records/$record_id" \
      --data "{\"content\":\"$current_ip\",\"ttl\":300}" >/dev/null
    echo "updated $name -> $current_ip (ttl 300)"
  fi
done

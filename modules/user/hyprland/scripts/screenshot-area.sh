mkdir -p ~/Media/Pictures/Screenshots
FILE="$HOME/Media/Pictures/Screenshots/$(date +%F_%T).png"
grim -g "$(slurp)" - | tee "$FILE" | wl-copy --type image/png
notify-send -t 2000 '󰹑 Screenshot' 'Area copied to clipboard'

mkdir -p ~/Media/Pictures/Screenshots
FILE="$HOME/Media/Pictures/Screenshots/$(date +%F_%T).png"
grim - | tee "$FILE" | wl-copy --type image/png
notify-send -t 2000 '󰹑 Screenshot' 'Full screen copied to clipboard'

mkdir -p ~/Pictures/Screenshots
FILE="$HOME/Pictures/Screenshots/$(date +%F_%T).png"
grim -g "$(slurp)" "$FILE"
notify-send -t 2000 '󰹑 Screenshot' 'Area saved to ~/Pictures/Screenshots'

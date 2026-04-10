mkdir -p ~/Pictures/Screenshots
FILE="$HOME/Pictures/Screenshots/$(date +%F_%T).png"
grim "$FILE"
notify-send -t 2000 '󰹑 Screenshot' 'Full screen saved to ~/Pictures/Screenshots'

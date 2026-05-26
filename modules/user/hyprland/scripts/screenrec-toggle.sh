SCREENCASTS_DIR="$HOME/Media/Videos/Screencasts"
mkdir -p "$SCREENCASTS_DIR"

if pgrep -x wl-screenrec > /dev/null; then
    pkill -SIGINT wl-screenrec
    notify-send -t 3000 "󰹙 Screen Recording" "Stopped — saved to Screencasts/"
else
    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    OUTPUT="$SCREENCASTS_DIR/screencast_${TIMESTAMP}.mp4"
    notify-send -t 2000 "󰑈 Screen Recording" "Recording started"
    wl-screenrec -f "$OUTPUT"
fi

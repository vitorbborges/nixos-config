mkdir -p ~/Media/Pictures/Screenshots
grim -g "$(slurp)" -t ppm - | satty --filename -

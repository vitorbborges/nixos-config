# Routes system audio to the ExceedShare virtual sink while the client is
# casting (its "ShareRecord" capture stream exists) and restores the laptop
# speakers/mic when casting stops. Runs as a background user service.

dummy_sink() { pactl list sinks short | awk '/snd_dummy/ {print $2; exit}'; }
dummy_monitor() { pactl list sources short | awk '/snd_dummy.*monitor/ {print $2; exit}'; }
real_sink() { pactl list sinks short | awk '/HiFi__Speaker__sink/ {print $2; exit}'; }
real_source() { pactl list sources short | awk '/alsa_input\.pci/ {print $2; exit}'; }

casting() {
    pactl list source-outputs | grep -q 'application.name = "ShareRecord"'
}

set_mode() {
    local sink source
    if [ "$1" = on ]; then
        sink=$(dummy_sink)
        source=$(dummy_monitor)
    else
        sink=$(real_sink)
        source=$(real_source)
    fi
    [ -n "$sink" ] || return 0

    pactl set-default-sink "$sink"
    if [ -n "$source" ]; then
        pactl set-default-source "$source"
    fi

    for id in $(pactl list sink-inputs short | cut -f1); do
        pactl move-sink-input "$id" "$sink" 2>/dev/null || true
    done

    if [ "$1" = on ] && [ -n "$source" ]; then
        for id in $(pactl list source-outputs short | cut -f1); do
            pactl move-source-output "$id" "$source" 2>/dev/null || true
        done
    fi
}

if casting; then
    set_mode on
    state=on
else
    state=off
fi

pactl subscribe | while read -r _ _ _ target _; do
    case "$target" in
    source-output* | server*) ;;
    *) continue ;;
    esac

    if casting; then want=on; else want=off; fi
    if [ "$want" != "$state" ]; then
        set_mode "$want"
        state="$want"
    fi
done

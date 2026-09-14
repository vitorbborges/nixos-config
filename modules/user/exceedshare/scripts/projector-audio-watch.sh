# Routes system audio to the ExceedShare virtual sink while the client is
# casting (its "ShareRecord" capture stream exists). When casting stops, the
# configured default-device pins are CLEARED (not pointed back at the laptop
# speakers) so WirePlumber re-evaluates and picks the best available device —
# which keeps Bluetooth auto-switching working after a cast ends.

dummy_sink() { pactl list sinks short | awk '/snd_dummy/ {print $2; exit}'; }
dummy_monitor() { pactl list sources short | awk '/snd_dummy.*monitor/ {print $2; exit}'; }

casting() {
    pactl list source-outputs | grep -q 'application.name = "ShareRecord"'
}

# Delete the "configured" default pins. WirePlumber treats them as explicit
# user choices (+30000 priority), so while they exist a freshly connected
# Bluetooth headset never becomes the default. Deleting also clears the
# persisted default-nodes state, so the pin doesn't survive a reboot either.
clear_default_pins() {
    pw-metadata -n default -d 0 default.configured.audio.sink
    pw-metadata -n default -d 0 default.configured.audio.source
}

move_sink_inputs_to() {
    local sink=$1
    [ -n "$sink" ] || return 0
    for id in $(pactl list sink-inputs short | cut -f1); do
        pactl move-sink-input "$id" "$sink" 2>/dev/null || true
    done
}

set_mode() {
    if [ "$1" = on ]; then
        sink=$(dummy_sink)
        source=$(dummy_monitor)
        [ -n "$sink" ] || return 0

        pactl set-default-sink "$sink"
        if [ -n "$source" ]; then
            pactl set-default-source "$source"
        fi

        move_sink_inputs_to "$sink"
        if [ -n "$source" ]; then
            for id in $(pactl list source-outputs short | cut -f1); do
                pactl move-source-output "$id" "$source" 2>/dev/null || true
            done
        fi
    else
        clear_default_pins
        # give WirePlumber's rescan a moment to settle on a default before
        # pulling any leftover streams off the virtual sink
        sleep 1
        move_sink_inputs_to "$(pactl get-default-sink)"
    fi
}

# Normalize immediately on start: also covers a reboot that happened while the
# configured-default pin was still pointing at the virtual sink.
if casting; then
    set_mode on
    state=on
else
    set_mode off
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

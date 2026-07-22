#!/bin/bash
# Win95-style Start Menu for Hyprland using rofi
# Supports toggle: clicking Start again kills the menu

if pgrep -f "rofi.*win95-start" > /dev/null 2>&1; then
    pkill -f "rofi.*win95-start"
    exit 0
fi

ROFI_THEME="$HOME/.config/rofi/win95-start.rasi"
ROFI_COMMON="-theme $ROFI_THEME -kb-cancel Escape,Super_L -show-icons"

main_menu() {
    printf 'Programs\x00icon\x1ffolder\n'
    printf 'Documents\x00icon\x1ffolder-documents\n'
    printf 'Find Files\x00icon\x1fedit-find\n'
    printf 'Run...\x00icon\x1fsystem-run\n'
    printf '───────────\n'
    printf 'Log Out\x00icon\x1fsystem-log-out\n'
    printf 'Sleep\x00icon\x1fsystem-suspend\n'
    printf 'Restart\x00icon\x1fsystem-reboot\n'
    printf 'Shut Down\x00icon\x1fsystem-shutdown\n'
}

programs_menu() {
    rofi -show drun \
        $ROFI_COMMON \
        -display-drun "Programs" \
        -drun-display-format "{name}" \
        -scroll-method 0
}

documents_menu() {
    local selected
    selected=$(find "$HOME/Documents" "$HOME/Downloads" -maxdepth 2 \
        -type f -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn | head -20 | cut -d' ' -f2- \
        | sed "s|$HOME/||" \
        | rofi -dmenu $ROFI_COMMON -p "Documents")
    [ -n "$selected" ] && xdg-open "$HOME/$selected" &
}

find_menu() {
    local query
    query=$(rofi -dmenu $ROFI_COMMON -p "Find Files" -lines 0 -filter "")
    [ -z "$query" ] && return

    local -a results
    if command -v fd &>/dev/null; then
        mapfile -t results < <(fd --max-depth 5 "$query" "$HOME" 2>/dev/null | head -30)
    else
        mapfile -t results < <(find "$HOME" -maxdepth 5 -iname "*${query}*" 2>/dev/null | head -30)
    fi

    [ ${#results[@]} -eq 0 ] && {
        notify-send "Find" "No results for '$query'" --icon=dialog-information
        return
    }

    local selected
    selected=$(printf '%s\n' "${results[@]}" \
        | sed "s|$HOME/||" \
        | rofi -dmenu $ROFI_COMMON -p "Results")
    [ -n "$selected" ] && xdg-open "$HOME/$selected" &
}

run_menu() {
    local cmd
    cmd=$(rofi -dmenu $ROFI_COMMON -p "Run" -lines 0 -filter "")
    [ -n "$cmd" ] && eval "$cmd" &
}

do_logout()   { hyprctl dispatch exit; }
do_sleep()    { systemctl suspend; }
do_restart()  { systemctl reboot; }
do_shutdown() { systemctl poweroff; }

selected=$(main_menu | rofi -dmenu \
    $ROFI_COMMON \
    -p "" \
    -selected-row 0 \
    -me-select-entry '' \
    -me-accept-entry 'MousePrimary' \
    -location 7 \
    -xoffset 2 \
    -yoffset -34)

case "$selected" in
    "Programs")    programs_menu ;;
    "Documents")   documents_menu ;;
    "Find Files")  find_menu ;;
    "Run...")       run_menu ;;
    "Log Out")     do_logout ;;
    "Sleep")       do_sleep ;;
    "Restart")     do_restart ;;
    "Shut Down")   do_shutdown ;;
esac

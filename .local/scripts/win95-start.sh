#!/bin/bash
# Win95-style Start Menu for Hyprland using rofi
# Supports toggle: clicking Start again kills the menu

# Toggle: if rofi is already running with our class, kill it and exit
if pgrep -f "rofi.*win95-start" > /dev/null 2>&1; then
    pkill -f "rofi.*win95-start"
    exit 0
fi

ROFI_THEME="$HOME/.config/rofi/win95-start.rasi"
ROFI_COMMON="-theme $ROFI_THEME -kb-cancel Escape,Super_L"

main_menu() {
    echo "📁 Programs"
    echo "📄 Documents"
    echo "🔍 Find Files"
    echo "▶ Run..."
    echo "───────────"
    echo "🚪 Log Out"
    echo "💤 Sleep"
    echo "🔄 Restart"
    echo "⏻ Shut Down"
}

programs_menu() {
    rofi -show drun \
        $ROFI_COMMON \
        -display-drun "Programs" \
        -drun-display-format "{name}" \
        -scroll-method 0
}

documents_menu() {
    selected=$(find "$HOME/Documents" "$HOME/Downloads" -maxdepth 2 \
        -type f \
        -printf '%T@ %p\n' 2>/dev/null \
        | sort -rn \
        | head -20 \
        | cut -d' ' -f2- \
        | sed "s|$HOME/||" \
        | rofi -dmenu \
            $ROFI_COMMON \
            -p "Documents")
    
    if [ -n "$selected" ]; then
        xdg-open "$HOME/$selected" &
    fi
}

find_menu() {
    query=$(rofi -dmenu \
        $ROFI_COMMON \
        -p "Find Files" \
        -lines 0 \
        -filter "")

    if [ -n "$query" ]; then
        if command -v fd &>/dev/null; then
            results=$(fd --max-depth 5 "$query" "$HOME" 2>/dev/null | head -30)
        else
            results=$(find "$HOME" -maxdepth 5 -iname "*${query}*" 2>/dev/null | head -30)
        fi

        if [ -n "$results" ]; then
            selected=$(echo "$results" \
                | sed "s|$HOME/||" \
                | rofi -dmenu \
                    $ROFI_COMMON \
                    -p "Results")
            
            if [ -n "$selected" ]; then
                fullpath="$HOME/$selected"
                if [ -d "$fullpath" ]; then
                    thunar "$fullpath" &
                else
                    xdg-open "$fullpath" &
                fi
            fi
        else
            notify-send "Find" "No results for '$query'" --icon=dialog-information
        fi
    fi
}

run_menu() {
    cmd=$(rofi -dmenu \
        $ROFI_COMMON \
        -p "Run" \
        -lines 0 \
        -filter "")

    if [ -n "$cmd" ]; then
        eval "$cmd" &
    fi
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
    "📁 Programs")    programs_menu ;;
    "📄 Documents")   documents_menu ;;
    "🔍 Find Files")  find_menu ;;
    "▶ Run...")        run_menu ;;
    "🚪 Log Out")     do_logout ;;
    "💤 Sleep")       do_sleep ;;
    "🔄 Restart")     do_restart ;;
    "⏻ Shut Down")   do_shutdown ;;
    "───────────")     ;; # separator
esac

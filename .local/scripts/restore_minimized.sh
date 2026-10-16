
#!/bin/bash
WINDOWS_JSON=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:special")]')
[ "$(echo "$WINDOWS_JSON" | jq 'length')" -eq 0 ] && exit 0

# Prefix each entry with its index so duplicates are unique
MENU=$(echo "$WINDOWS_JSON" | jq -r 'to_entries[] | "\(.key)  \(.value.title) [\(.value.class)]"')
SELECTED=$(echo "$MENU" | wofi --dmenu --prompt "Restore:")
[ -z "$SELECTED" ] && exit 0

# Pull address by index, not by title
IDX=$(echo "$SELECTED" | awk '{print $1}')
ADDRESS=$(echo "$WINDOWS_JSON" | jq -r ".[$IDX].address")
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl dispatch movetoworkspace "$CURRENT_WS,address:$ADDRESS"











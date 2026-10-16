#!/bin/bash
COUNT=$(hyprctl clients -j | jq '[.[] | select(.workspace.name == "special:special")] | length')
if [ "$COUNT" -gt 0 ]; then
    echo "{\"text\": \"🗕 $COUNT\", \"class\": \"minimized\"}"
else
    echo "{\"text\": \"🗕\", \"class\": \"\"}"
fi

function ask --description 'Prompt llama-server (localhost on madness, Tailscale elsewhere)'
    if test (count $argv) -eq 0
        echo 'usage: ask "your question"' >&2
        return 1
    end

    set -l base
    if test (uname -n) = madness
        set base http://localhost:8080
    else
        set base http://100.64.156.9:8080
    end

    set -l payload (jq -nc --arg m "$argv" '{messages:[{role:"user",content:$m}],max_tokens:1024}')
    curl -s "$base/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$payload" \
    | jq -r '
        .choices[0].message
        | if (.content // "") != "" then .content
          else (.reasoning_content // "error: empty response") end
      '
end

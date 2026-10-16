function fish_prompt
    set -l cwd (prompt_pwd --full-length-dirs 99 | sed 's|/|\\\\|g' | tr '[:lower:]' '[:upper:]')
    set_color --bold white
    echo -n "C:\\$cwd> "
    set_color normal
end

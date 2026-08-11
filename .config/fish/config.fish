# --- PATHS ---
fish_add_path -g ~/.bun/bin
fish_add_path -g ~/.cache/.bun/bin
fish_add_path -g ~/.pyenv/bin
fish_add_path -g ~/.local/bin
fish_add_path -g ~/explore/flutter/bin
fish_add_path -g ~/.cargo/bin
set fish_greeting ""

starship init fish | source

# --- INIT SCRIPTS ---
# Initialize Pyenv
if command -v pyenv 1>/dev/null 2>&1
    pyenv init - | source
end

# Initialize Starship Prompt
if command -v starship 1>/dev/null 2>&1
    starship init fish | source
end

# --- ALIASES ---
alias py='python3'
alias pyy='python3.14'
alias cls='clear'
alias ls='ls --color=auto'
alias ll='ls -lh --color=auto'
alias la='ls -lah --color=auto'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'
alias ..='cd ..'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gplo='git pull origin'
alias update='yay -Syu'
alias conf='cd ~/.config'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'
alias push-config='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME push origin main'
alias dps='docker ps'
alias drm='docker rm -f'
alias codexsession='tmux new -A -s codex'

# --- FUNCTIONS ---
function current_time
    date +"%H:%M"
end

function dirsize
    set target $argv[1]
    if test -z "$target"
        set target "."
    end
    du -sh "$target" | sort -hr
end

function extract
    if test -f "$argv[1]"
        switch "$argv[1]"
            case '*.tar.bz2' '*.tbz2'
                tar xjf "$argv[1]"
            case '*.tar.gz' '*.tgz'
                tar xzf "$argv[1]"
            case '*.bz2'
                bunzip2 "$argv[1]"
            case '*.rar'
                unrar e "$argv[1]"
            case '*.gz'
                gunzip "$argv[1]"
            case '*.tar'
                tar xf "$argv[1]"
            case '*.zip'
                unzip "$argv[1]"
            case '*.Z'
                uncompress "$argv[1]"
            case '*.7z'
                7z x "$argv[1]"
            case '*'
                echo "'$argv[1]' cannot be extracted"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

function mkcd
    mkdir -p "$argv[1]"
    and cd "$argv[1]"
end

function weather
    set target $argv[1]
    curl -s "wttr.in/$target?q&format=3"
end

# --- AUTOSTART HYPRLAND ---
if status is-login
    if uwsm check may-start
        exec uwsm start hyprland.desktop >/dev/null 2>&1
    end
end

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<

# opencode
fish_add_path /home/marc/.opencode/bin

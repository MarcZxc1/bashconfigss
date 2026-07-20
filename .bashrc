#
# ~/.bashrc
#

# ~/.bashrc: Aesthetically Pleasing Bash Configuration
# (Merged: New Design + Retained Functions/Aliases)

# --- INITIAL SETTINGS ---
[ -z "$PS1" ] && return
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s checkwinsize
shopt -s cdspell
shopt -s cmdhist

# --- COLOR DEFINITIONS (For Functions) ---
RESET="\[\033[0m\]"
BOLD_GREEN="\[\033[1;32m\]"
BOLD_RED="\[\033[1;31m\]"
BOLD_CYAN="\[\033[1;36m\]"
BOLD_BLUE="\[\033[1;34m\]"
YELLOW="\[\033[0;33m\]"
MAGENTA="\[\033[0;35m\]"
WHITE="\[\033[0;37m\]"

# --- RETAINED FUNCTIONS ---
parse_git_status() {
    local git_status=$(git status -s 2> /dev/null)
    local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [ -n "$branch" ]; then
        local indicators=""
        [[ "$git_status" =~ "??" ]] && indicators+="?"
        [[ "$git_status" =~ " M"|" A"|" D" ]] && indicators+="*"
        [[ "$git_status" =~ ^M|^A|^D ]] && indicators+="+"
        echo -n " (${branch}${indicators:+|${indicators}})"
    fi
}

current_time() { date +"%H:%M"; }

dirsize() { du -sh "${1:-.}" | sort -hr; }

extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2|*.tbz2) tar xjf "$1" ;;
            *.tar.gz|*.tgz)   tar xzf "$1" ;;
            *.bz2)            bunzip2 "$1" ;;
            *.rar)            unrar e "$1"   ;;
            *.gz)             gunzip "$1"    ;;
            *.tar)            tar xf "$1"    ;;
            *.zip)            unzip "$1"     ;;
            *.Z)              uncompress "$1";;
            *.7z)             7z x "$1"      ;;
            *)                echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

mkcd() { mkdir -p "$1" && cd "$1"; }

weather() { curl -s "wttr.in/${1:-}?q&format=3"; }

# --- RETAINED ALIASES ---
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
alias update='yay -Syu' # FIXED FOR ARCH LINUX!
alias conf='cd ~/.config'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'
alias push-config='/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME push origin main'
alias dps='docker ps'
alias drm='docker rm -f'

# --- NEW VISUAL DESIGN (POWERLINE STYLE) ---
if [[ ${EUID} == 0 ]] ; then
    # Root Prompt (Red/Blue Theme)
    PS1="\[\033[48;2;221;75;57;38;2;255;255;255m\] # \[\033[48;2;0;135;175;38;2;221;75;57m\]\[\033[48;2;0;135;175;38;2;255;255;255m\] \u \[\033[48;2;83;85;85;38;2;0;135;175m\]\[\033[48;2;83;85;85;38;2;255;255;255m\] \w \[\033[49;38;2;83;85;85m\]\[\033[00m\]${MAGENTA}\$(parse_git_status)${RESET}"
else
    # User Prompt (Nord Theme)
    PS1="\[\033[48;2;136;192;208;38;2;46;52;64m\] $ \[\033[48;2;94;129;172;38;2;136;192;208m\]\[\033[48;2;94;129;172;38;2;216;222;233m\] \u \[\033[48;2;59;66;82;38;2;94;129;172m\]\[\033[48;2;59;66;82;38;2;216;222;233m\] \w \[\033[49;38;2;59;66;82m\]\[\033[00m\]${BOLD_BLUE}\$(parse_git_status)${RESET} "
fi


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.bun/bin:$PATH"
export PATH="/home/marc/.cache/.bun/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/explore/flutter/bin"


# Added by Antigravity CLI installer
export PATH="/home/marc/.local/bin:$PATH"
. "$HOME/.cargo/env"

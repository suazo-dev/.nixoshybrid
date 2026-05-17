# PATH
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.pixi/bin:/home/suazo/.pixi/bin:$PATH"
export GOPATH=/opt/go
export PATH="$GOPATH/bin:$HOME/.cargo/bin:$HOME/.opencode/bin:/home/suazo/.opencode/bin:$PATH"
typeset -U path PATH

# Defaults
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export SUDO_EDITOR="nvim"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export MANPAGER="nvim +Man!"
export MANWIDTH=999

[ -f "$HOME/.config/zsh/host-flags.zsh" ] && source "$HOME/.config/zsh/host-flags.zsh"

# Catppuccin Mocha
if command -v vivid >/dev/null 2>&1; then
  _vivid_lscolors="$(vivid generate catppuccin-mocha 2>/dev/null)"
  if [[ -n "$_vivid_lscolors" ]]; then
    export LS_COLORS="$_vivid_lscolors"
  fi
  unset _vivid_lscolors
fi

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"

export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border=rounded
  --prompt='  '
  --pointer=''
  --marker='✓'
  --color=bg:#1e1e2e,bg+:#313244,fg:#cdd6f4,fg+:#cdd6f4
  --color=hl:#f38ba8,hl+:#f38ba8,info:#cba6f7,prompt:#cba6f7
  --color=pointer:#f5e0dc,marker:#a6e3a1,spinner:#f5e0dc,header:#f38ba8
  --color=border:#45475a
"

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"

# Transient prompt -- do not change this
TRANSIENT_PROMPT_TRANSIENT_PROMPT="%F{74c7ec}%f"
zinit light olets/zsh-transient-prompt

# Zsh core
autoload -Uz compinit edit-command-line magic-space zmv select-word-style
zmodload zsh/complist 2>/dev/null || true

select-word-style bash
WORDCHARS="${WORDCHARS//\/}"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt inc_append_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks

# Shell behavior
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent
setopt extended_glob
setopt no_case_glob
setopt complete_in_word
setopt always_to_end

# Completion style
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' squeeze-slashes true

zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -la --color=always --icons --group-directories-first $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -la --color=always --icons --group-directories-first $realpath'

# Completion init
zinit light zsh-users/zsh-completions

# Filter out missing completion dirs (e.g. homebrew on nix-managed macs)
fpath=(${fpath:#/opt/homebrew/share/zsh/site-functions})

if [[ "${ZSH_HOST_HEADLESS:-0}" == "1" ]]; then
  compinit -C
else
  compinit
fi

zinit cdreplay -q

# OMZ snippets without full Oh My Zsh
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Better completions
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  source <(carapace _carapace)
fi

# Plugins after compinit
zinit light Aloxaf/fzf-tab

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
zinit light zsh-users/zsh-autosuggestions

unset ZSH_HIGHLIGHT_STYLES
unset ZSH_HIGHLIGHT_PATTERNS
zinit light zsh-users/zsh-syntax-highlighting

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=#313244,fg=#cdd6f4,bold"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=#f38ba8,fg=#11111b,bold"
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
zinit light zsh-users/zsh-history-substring-search

# Keys
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down

bindkey '^x^e' edit-command-line
bindkey ' ' magic-space
bindkey '^[w' kill-region
bindkey '^_' undo
bindkey '^[r' redo
bindkey '^[[C' autosuggest-accept
bindkey '^[f' autosuggest-forward-word

# Aliases
alias c='clear'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias edit='nvim'
alias open='nvim'

alias ls='eza -la --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias tree='eza --tree -L 2 --icons'

alias cat='bat'
alias grep='rg'
alias rg='rg'
alias f='fzf'
alias zz='zoxide query -i'

alias lg='lazygit'
alias top='btop'
alias df='duf'
alias ducks='dust'
alias md='glow'
alias dns='dog'
alias bench='hyperfine'

# Repo jumps
.n() { cd "${NIXCFG_ROOT:-$HOME/.nixos}"; }
.rs() { cd ~/Code; }
.cmp() { cd "${NIXCFG_ROOT:-$HOME/.nixos}/components"; }
.ft() { cd "${NIXCFG_ROOT:-$HOME/.nixos}/features"; }
.mx() { cd "${NIXCFG_ROOT:-$HOME/.nixos}/machines"; }
.z() { cd "${NIXCFG_ROOT:-$HOME/.nixos}/modules/terminal/zsh/dotfiles/"; }

# Global pipe aliases
alias -g G='| grep'
alias -g R='| rg'
alias -g H='| head'
alias -g T='| tail'
alias -g L='| less'
alias -g C='| wc -l'
alias -g N='> /dev/null 2>&1'

ndev() { nix develop "$@"; }
nrun() { nix develop -c "$@"; }
fshow() { nix flake show "$@"; }
fupdate() { nix flake update "$@"; }

dallow() { direnv allow; }
dreload() { direnv reload; }
dstatus() { direnv status; }

# WireGuard helpers
wgon() {
  if [[ -z "$1" ]]; then
    echo "usage: wgon <wg0|wg1>"
    return 1
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v open >/dev/null 2>&1; then
      open -a WireGuard >/dev/null 2>&1 || true
    fi
    echo "manage WireGuard tunnels from the WireGuard app on macOS"
    return 0
  fi

  sudo systemctl restart "wg-quick-$1"
}

wgoff() {
  if [[ -z "$1" ]]; then
    echo "usage: wgoff <wg0|wg1>"
    return 1
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if command -v open >/dev/null 2>&1; then
      open -a WireGuard >/dev/null 2>&1 || true
    fi
    echo "manage WireGuard tunnels from the WireGuard app on macOS"
    return 0
  fi

  sudo systemctl stop "wg-quick-$1"
}

alias wg0on='wgon wg0'
alias wg0off='wgoff wg0'
alias wg1on='wgon wg1'
alias wg1off='wgoff wg1'

# Rebuild
rb() {
  local name="${1:-$(hostname)}"
  cd ~/.nixoshybrid && git pull
  if [[ "$(uname)" == "Darwin" ]]; then
    sudo darwin-rebuild switch --flake "$HOME/.nixoshybrid#$name"
  else
    sudo nixos-rebuild switch --flake "$HOME/.nixoshybrid#$name"
  fi
}
alias rbtiny='rb tiny'
alias rbmama='rb mama'
alias rbslim='rb slim'
alias rbtee='rb tee'
alias rbpapa='rb papa'

# SSH
alias sshtiny='ssh suazo@tiny'
alias sshmama="TERM=xterm-256color ssh -t suazo@mama 'LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 tmux -u new -As main'"
alias sshpapa="TERM=xterm-256color ssh -t suazo@papa 'LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 tmux -u new -As main'"
alias sshslim='ssh suazo@slim'
alias sshtee='ssh suazo@tee'

# Wake on LAN
alias waketiny='wakeonlan 00:23:24:73:05:91'
alias wakemama='wakeonlan c4:65:16:b6:8c:3c'

# VNC
alias vncpapa='remmina -c vnc://suazo@10.0.0.3'

# Fuzzy helpers
cdf() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf) && cd "$dir"
}

nvf() {
  local file
  file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always {}') && nvim "$file"
}

rgf() {
  rg --line-number --hidden --glob "!.git" "$@" | fzf --ansi
}

gitf() {
  local file
  file=$(git ls-files 2>/dev/null | fzf --preview 'bat --style=numbers --color=always {}') && nvim "$file"
}

gcbf() {
  local branch
  branch=$(git branch --all --color=always | sed 's/^[* ] //' | fzf --ansi | sed 's#remotes/origin/##') && git checkout "$branch"
}

mdf() {
  local file
  file=$(fd --extension md --hidden --exclude .git | fzf --preview 'glow {}') && glow "$file"
}

readme() {
  if [[ -f README.md ]]; then
    glow README.md
  else
    glow
  fi
}

# System helpers
pathlines() {
  echo "$PATH" | tr ':' '\n'
}

biggest() {
  du -ah "${1:-.}" 2>/dev/null | sort -h | tail -n 30
}

ips() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ifconfig | awk '
      /^[A-Za-z0-9]/ {
        iface=$1
        sub(":", "", iface)
      }
      /inet / && $2 != "127.0.0.1" {
        printf "%s\tipv4\t%s\n", iface, $2
      }
      /inet6 / && $2 != "::1" {
        printf "%s\tipv6\t%s\n", iface, $2
      }
    '
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "missing dependency: jq"
    return 1
  fi

  ip -j addr | jq '.[] | {
    interface: .ifname,
    state: .operstate,
    addresses: [.addr_info[]? | { family, local, prefixlen }]
  }'
}

ports() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    lsof -nP -iTCP -sTCP:LISTEN -iUDP | awk '
      NR == 1 {
        printf "%-6s %-24s %s\n", "PROTO", "LOCAL", "PROCESS"
        next
      }
      {
        printf "%-6s %-24s %s[%s]\n", $8, $9, $1, $2
      }
    '
    return 0
  fi

  ss -H -tulpn | awk '
    {
      proto=$1
      local=$5
      proc=$0
      sub(/^.*users:\(\(*/, "", proc)
      sub(/\)\).*/, "", proc)
      if (proc == $0) proc="-"
      printf "%-6s %-24s %s\n", proto, local, proc
    }
  '
}

compare() {
  if [[ "$#" -lt 2 ]]; then
    echo "usage: compare '<cmd1>' '<cmd2>'"
    return 1
  fi

  hyperfine "$@"
}

help() {
  "$@" --help 2>&1 | bat --plain --language=help
}

# Nushell
nush() {
  if ! command -v nu >/dev/null 2>&1; then
    echo "nushell is not installed"
    return 1
  fi

  echo "Entering Nushell. Type 'exit' to return to Zsh."
  nu
}

# Config helpers
reload() {
  source ~/.zshrc
}

zshrc() {
  nvim "${NIXCFG_ROOT:-$HOME/.nixos}/modules/terminal/zsh/dotfiles/.zshrc"
}

# Integrations
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow --disable-ai)"
fi

[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

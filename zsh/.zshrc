# =============================================================================
#                          Pre-Plugin Configuration
# =============================================================================

# Automagically quote URLs. This obviates the need to quote them manually when
# pasting or typing URLs.
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# =============================================================================
#                                   Plugins
# =============================================================================

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow,bold'

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  mkdir -p "$(dirname "${ZINIT_HOME}")"
  git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}" || true
fi
if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
  source "${ZINIT_HOME}/zinit.zsh"
fi

if (( $+functions[zinit] )); then
  if command -v bundle >/dev/null 2>&1; then zinit snippet OMZP::bundler; fi
  zinit snippet OMZP::colored-man-pages
  zinit snippet OMZP::extract
  zinit snippet OMZP::fancy-ctrl-z
  zinit snippet OMZP::sudo
  if command -v git >/dev/null 2>&1; then zinit snippet OMZP::git; fi
  if command -v http >/dev/null 2>&1; then zinit snippet OMZP::httpie; fi
  if command -v nmap >/dev/null 2>&1; then zinit snippet OMZP::nmap; fi

  zinit light b4b4r07/zsh-vimode-visual
  zinit light jeffreytse/zsh-vi-mode
  zinit light seebi/dircolors-solarized
  zinit light Tarrasch/zsh-bd
  zinit light zsh-users/zsh-autosuggestions
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-history-substring-search
  zinit light zsh-users/zsh-syntax-highlighting
fi

if (( $+functions[zinit] )); then
  if which gdircolors > /dev/null 2>&1; then
    alias dircolors='gdircolors'
  fi
  if which dircolors > /dev/null 2>&1; then
    scheme='dircolors.256dark'
    dircolors_repo="${ZINIT_HOME}/plugins/seebi---dircolors-solarized"
    [[ -f "${dircolors_repo}/${scheme}" ]] && eval "$(dircolors "${dircolors_repo}/${scheme}")"
  fi
fi

if (( $+functions[_zsh_autosuggest_start] )); then
  # Enable asynchronous fetching of suggestions.
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  # For some reason, the offered completion winds up having the same color as
  # the terminal background color (when using a dark profile). Therefore, we
  # switch to gray.
  # See https://github.com/zsh-users/zsh-autosuggestions/issues/182.
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=gray'
fi

# Our custom version of oh-my-zsh's globalias plugin. Unlike the OMZ version,
# we do not use the `expand-word' widget and only expand a few whitelisted
# aliases.
# See https://github.com/robbyrussell/oh-my-zsh/issues/6123 for discussion.
globalias() {
  # FIXME: the whitelist pattern should technically only be computed once, but
  # since it's cheap, we keep it local for now.
  local -a whitelist candidates
  whitelist=(ls git)
  local pattern="^(${(j:|:)whitelist})"
  for k v in ${(kv)aliases}; do
    # We have a candidate unless the alias is an alias that begins with itself,
    # e.g., ls='ls --some-option'.
    if [[ $v =~ $pattern && ! $v =~ ^$k ]]; then
      candidates+=($k)
    fi
  done
  if [[ $LBUFFER =~ "(^|[;|&])\s*(${(j:|:)candidates})\s*($|[;|&])" ]]; then
    zle _expand_alias
  fi
  zle self-insert
}
zle -N globalias
bindkey -M emacs ' ' globalias
bindkey -M viins ' ' globalias
bindkey -M isearch ' ' magic-space # normal space during searches


# =============================================================================
#                                   Options
# =============================================================================

# Watching other users
WATCHFMT='%n %a %l from %m at %t.'
watch=(notme)         # Report login/logout events for everybody except ourself.
LOGCHECK=60           # Time (seconds) between checks for login/logout activity.
REPORTTIME=5          # Display usage statistics for commands running > 5 sec.
WORDCHARS="\'*?_-.[]~=/&;!#$%^(){}<>\'"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt autocd                   # Allow changing directories without `cd`
setopt append_history           # Do not overwrite history
setopt extended_history         # Also record time and duration of commands.
setopt share_history            # Share history between multiple shells
setopt hist_expire_dups_first   # Clear duplicates when trimming internal hist.
setopt hist_find_no_dups        # Do not display duplicates during searches.
setopt hist_ignore_dups         # Ignore consecutive duplicates.
setopt hist_ignore_all_dups     # Remember only one unique copy of the command.
setopt hist_reduce_blanks       # Remove superfluous blanks.
setopt hist_save_no_dups        # Omit older commands in favor of newer ones.

# Changing directories
setopt pushd_ignore_dups        # Do not push copies of the same dir on stack.
setopt pushd_minus              # Reference stack entries with '-'.

setopt extended_glob

# =============================================================================
#                                   Aliases
# =============================================================================


# Swift editing and file display.
alias e="$EDITOR"
alias v="$VISUAL"

alias docker="nerdctl"

# FZF
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--height 30%
      --color fg:223,bg:235,hl:208,fg+:229,bg+:237,hl+:167,border:237
      --color info:246,prompt:214,pointer:214,marker:142,spinner:246,header:214'
fi

# =============================================================================
#                                 Completions
# =============================================================================

# case-insensitive (all), partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# When doing `cd ../<TAB>`, don't offer the current directory as an option.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Show a menu (with arrow keys) to select the process to kill.
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

# =============================================================================
#                                    Other
# =============================================================================

# Convenience function to update system applications and user packages.
update() {
  # sudoe once
  if ! sudo -n true 2> /dev/null; then
    sudo -v
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
    done 2>/dev/null &
  fi
  # System
  sudo softwareupdate -i -a
  # Homebrew
  brew upgrade
  brew cleanup
  # npm
  npm install npm -g
  npm update -g
  # Shell plugin management
  if (( $+functions[zinit] )); then
    zinit self-update && zinit update --all || true
  fi
  # Neovim plugin management (lazy.nvim via AstroNvim)
  if command -v nvim >/dev/null 2>&1; then
    nvim --headless "+Lazy! sync" +qa || true
  fi
}

# =============================================================================
#                                   Startup
# =============================================================================

# Source local customizations.
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

export NODE_EXTRA_CA_CERTS=/System/Volumes/Data/opt/homebrew/etc/ca-certificates/cert.pem

if command -v security >/dev/null 2>&1; then
  brew_token="$(security find-generic-password -w -s 'GITHUB' -a 'HOMEBREW_GITHUB_API_TOKEN' 2>/dev/null || true)"
  if [[ -n "$brew_token" ]]; then
    export HOMEBREW_GITHUB_API_TOKEN="$brew_token"
  fi
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# Setup GPG for user accounts.
if [[ $UID != 0 ]]; then
  export GPG_TTY=$(tty);
  if which gpgconf > /dev/null 2>&1; then
    export GPG_AGENT_INFO=$(gpgconf --list-dirs agent-socket)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

    #gpgconf --launch gpg-agent > /dev/null
    gpg-connect-agent updatestartuptty /bye > /dev/null
  fi
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export DENO_INSTALL="$HOME/.deno"
export DOTNET_CLI_TELEMETRY_OPTOUT="1"

#todo:set into separate file
if command -v security >/dev/null 2>&1; then
  openai_key="$(security find-generic-password -w -s 'OPEN_API' -a 'ACCESS_KEY' 2>/dev/null || true)"
  if [[ -n "$openai_key" ]]; then
    export OPENAI_API_KEY="$openai_key"
  fi
fi
export OPENAI_API_HOST="api.openai.com"
eval "$(fnm env --use-on-cd)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export rpath="/opt/homebrew/lib/"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

if [[ -f "$HOME/.config/broot/launcher/bash/br" ]]; then
  source "$HOME/.config/broot/launcher/bash/br"
fi

autoload -Uz compinit && compinit
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
eval "$(pyenv init -)"

# ZSH config

# Load Compinit for completion support
autoload -U compinit
compinit

# allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD
## history
setopt APPEND_HISTORY
## for sharing history between zsh processes
setopt INC_APPEND_HISTORY
# setopt SHARE_HISTORY
unsetopt SHARE_HISTORY

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
MAILCHECK=0

# autoload -U colors
autoload -U colors
# allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

export HISTFILE=~/.zsh_history
export XDG_DATA_HOME=~/.local/share/

setopt promptsubst

zinit snippet OMZL::git.zsh

omz_libraries=(
    prompt_info_functions.zsh
    key-bindings.zsh
    history.zsh
    completion.zsh
)
for library in ${omz_libraries[@]}; do
    zinit snippet OMZL::$library
    done

# list of omzsh plugins to enable
omz_plugins=(
    common-aliases
    command-not-found # Needs command-not-found installed
    git
)
# load the omzsh plugins
for plugin in ${omz_plugins[@]}; do
    # zinit snippet OMZ::plugins/$plugin/$plugin.plugin.zsh
    zinit snippet OMZP::$plugin
    done

# Fish-like autosuggestions
zinit light zsh-users/zsh-autosuggestions
# Colourful commands
zinit light zdharma/fast-syntax-highlighting

# Plugin history-search-multi-word
zinit load zdharma/history-search-multi-word
zinit load zsh-users/zsh-history-substring-search


# Extra zsh completions
zinit light zsh-users/zsh-completions
# Frequency match jump to dir
zinit load agkozak/zsh-z

# Theme blocks
#
# Spaceship Prompt Theme block
zinit light denysdovhan/spaceship-prompt

SPACESHIP_TIME_SHOW=true
SPACESHIP_VI_MODE_SHOW=true

# Bullet Train Block
#zinit light caiogondim/bullet-train-oh-my-zsh-theme 

#bullet train vi mode customizations
function zle-line-init zle-keymap-select {
    case ${KEYMAP} in
        (vicmd)      BULLETTRAIN_PROMPT_CHAR="[N]$" ;;
        (main|viins) BULLETTRAIN_PROMPT_CHAR="[I]$" ;;
        (*)          BULLETTRAIN_PROMPT_CHAR="[I]$" ;;
    esac
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# Set up NVM
zinit ice wait"1" lucid
zinit light lukechilds/zsh-nvm
zinit light lukechilds/zsh-better-npm-completion

# Load rbenv automatically by appending
# the following to ~/.zshrc:
#eval "$(rbenv init -)"

# Syntax Highlighting with less (must install source-highlight)
export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
export LESS=' -NR '

#activate vim mode
bindkey -v
#bindkey "^R" history-incremental-search-backward
bindkey "^R" history-search-multi-word

alias st=sublime
alias l='/bin/ls -alFh'

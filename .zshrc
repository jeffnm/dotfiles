# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Antigen Source
source ~/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh)
antigen bundle git
antigen bundle zsh-users/zsh-history-substring-search
antigen bundle zsh-users/zsh-completions
antigen bundle z
antigen bundle zsh-users/zsh-autosuggestions

# Syntax highlighting bundle.
antigen bundle zdharma/fast-syntax-highlighting

# Load the theme.
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

# Tell Antigen that you're done.
antigen apply

# spaceship theme customization options
SPACESHIP_TIME_SHOW=true
SPACESHIP_VI_MODE_SHOW=true


# vim mode config
# ---------------

# Activate vim mode.
bindkey -v
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Remove mode switching delay.
KEYTIMEOUT=1

# Deno completions
#source /usr/local/etc/zsh_completion.d/deno.zsh

alias st=/usr/local/bin/sublime
alias -s php=sublime



export PATH="/usr/local/sbin:$PATH"

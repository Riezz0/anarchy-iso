#Startups
fastfetch

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Theme
ZSH_THEME="agnoster"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete autoswitch_virtualenv $plugins)

# Import
source $ZSH/oh-my-zsh.sh

# aliases
alias v="nvim"
alias ls="eza -lag --icons"
alias ga="git add ."
alias gc="git commit --allow-empty-message -m "
alias gp="git push -u origin main"


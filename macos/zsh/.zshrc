
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
# ZSH_THEME="robbyrussell"
eval "$(starship init zsh)"
# source "/opt/homebrew/opt/spaceship/spaceship.zsh"

# Imports de configs do ZSH
[[ -f ~/.zsh/plugins.zsh ]] && source ~/.zsh/plugins.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
# [[ -f ~/.zsh/pyenv.zsh ]] && source ~/.zsh/pyenv.zsh
# [[ -f ~/.zsh/spaceship.zsh ]] && source ~/.zsh/spaceship.zsh
# [[ -f ~/.zsh/zinit.zsh ]] && source ~/.zsh/zinit.zsh

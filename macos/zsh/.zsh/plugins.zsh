# Plugins core

plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

# Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax Highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source $ZSH/oh-my-zsh.sh

# Completions
fpath+=($(brew --prefix)/share/zsh-completions)
autoload -Uz compinit
compinit
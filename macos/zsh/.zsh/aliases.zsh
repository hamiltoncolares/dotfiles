# 📂 Navegação
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias c="clear"
alias dev="cd ~/Developer"

# 📜 Listagem de arquivos
alias ls="eza --icons"
alias ll="eza -l --icons"
alias la="eza -lha --icons"
alias lt="eza --tree --level=2 --icons"

# # 📜 Listagem de arquivos
# alias ls="lsd -a"
# alias ll="lsd -l"
# alias la="lsd -la"
# alias lt="lsd --tree --level 2"

# 📑 Arquivos e busca
alias cat="bat"
alias grep="grep --color=auto"
alias f="fzf"

# 🐙 Git
alias g="git"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gs="git status -sb"
alias gb="git branch"
alias gco="git checkout"
alias gcm="git checkout main"
alias gd="git diff"
alias glog="git log --oneline --graph --decorate --all"

# 📦 Pacotes / Sistema
alias brewup="brew update && brew upgrade && brew cleanup"
alias path='echo -e ${PATH//:/\\n}'

# 🐳 Docker
alias d="docker"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias dbash="docker exec -it"

# ☁️ AWS CLI
alias awsp="aws sso login --profile"
alias awsls="aws s3 ls"
alias awscp="aws s3 cp"
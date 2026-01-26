#!/usr/bin/env bash
# backup_mac_tahoe.sh
# Autor: ChatGPT
# Descrição: Gera um backup seletivo (dados + configurações) e inventários de apps
#            para preparar uma instalação limpa do macOS Tahoe.
# Uso: bash backup_mac_tahoe.sh
# Requisitos recomendados: Homebrew, mas, tar, shasum (shasum é nativo no macOS)

set -euo pipefail

### ---------------------- Configurações do usuário ----------------------- ###
# Altere esta lista se quiser incluir/excluir pastas.
DATA_DIRS=(
  "$HOME/Documents"
  "$HOME/Desktop"
  "$HOME/Pictures"
  "$HOME/Movies"
  "$HOME/Music"
  "$HOME/Downloads"        # Inclua apenas se necessário
)

# Subpastas específicas de apps em Application Support que costumam ser importantes.
APP_SUPPORT_DIRS=(
  "$HOME/Library/Application Support/Raycast"
  "$HOME/Library/Application Support/Code"                  # VS Code
  "$HOME/Library/Application Support/Google/Chrome"
  "$HOME/Library/Application Support/com.raycast.macos"
  "$HOME/Library/Application Support/com.mitchellh.ghostty"
  "$HOME/Library/Application Support/dev.warp.Warp-Stable"
  "$HOME/.warp"
  "$HOME/Library/Application Support/com.mitchellh.ghostty"
)

# Pastas/arquivos de configuração úteis.
CONFIG_PATHS=(
  "$HOME/.zshrc"
  "$HOME/.zprofile"
  "$HOME/.zshenv"
  "$HOME/.bash_profile"
  "$HOME/.bashrc"
  "$HOME/.gitconfig"
  "$HOME/.gitignore_global"
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/Library/Preferences"
  "$HOME/Library/Keychains"
  "$HOME/Library/Fonts"
)

# Itens do sistema que valem inventário (não copiaremos tudo do /etc).
SYSTEM_FILES=(
  "/etc/hosts"
)

### ---------------------- Início do processo ----------------------------- ###

DATE_TAG="$(date +%Y-%m-%d_%H-%M)"
BACKUP_ROOT="/Volumes/ADATA/Backup_MacMini_Tahoe_${DATE_TAG}"
META_DIR="$BACKUP_ROOT/_inventarios"
LOG_FILE="$BACKUP_ROOT/_log.txt"

mkdir -p "$BACKUP_ROOT" "$META_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "==> Iniciando backup seletivo em: $BACKUP_ROOT"
echo "==> Data/Hora: $(date)"
echo

copy_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "Copiando: $path"
    rsync -aH --exclude="Cache" --exclude="Caches" --exclude=".cache" "$path" "$BACKUP_ROOT/"
  else
    echo "Aviso: não encontrado -> $path"
  fi
}

### 1) Copiar dados pessoais
echo "==> [1/7] Dados pessoais"
for d in "${DATA_DIRS[@]}"; do
  copy_if_exists "$d"
done
echo

### 2) Application Support (seleção) e configs
echo "==> [2/7] Configurações e Application Support (seleção)"
for d in "${APP_SUPPORT_DIRS[@]}"; do
  copy_if_exists "$d"
done

for c in "${CONFIG_PATHS[@]}"; do
  copy_if_exists "$c"
done

for s in "${SYSTEM_FILES[@]}"; do
  copy_if_exists "$s"
done
echo

### 3) Inventários de aplicativos
echo "==> [3/7] Inventários de aplicativos"

# Descobrir caminho do Homebrew (Apple Silicon vs Intel)
BREW_BIN=""
if command -v brew >/dev/null 2>&1; then
  BREW_BIN="$(command -v brew)"
elif [[ -x "/opt/homebrew/bin/brew" ]]; then
  BREW_BIN="/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
  BREW_BIN="/usr/local/bin/brew"
fi

if [[ -n "$BREW_BIN" ]]; then
  echo "Homebrew encontrado: $BREW_BIN"
  # Brewfile completo (melhor para restauração)
  "$BREW_BIN" bundle dump --file="$META_DIR/Brewfile" --force || true
  # Listas simples
  "$BREW_BIN" list --formula  > "$META_DIR/brew_formulas.txt"  || true
  "$BREW_BIN" list --cask     > "$META_DIR/brew_casks.txt"     || true
  "$BREW_BIN" leaves          > "$META_DIR/brew_leaves.txt"    || true
  "$BREW_BIN" services list   > "$META_DIR/brew_services.txt"  || true
else
  echo "Homebrew não encontrado. Pulando inventário do brew."
fi

# Mac App Store (mas-cli)
if command -v mas >/dev/null 2>&1; then
  mas list > "$META_DIR/apps_mas.txt" || true
else
  echo "mas não encontrado. Instale com: brew install mas"
fi

# Lista de apps em /Applications (útil quando app não veio da Store nem do brew)
ls -1 /Applications > "$META_DIR/applications_dir_list.txt" || true

# VSCode extensões
if command -v code >/dev/null 2>&1; then
  code --list-extensions > "$META_DIR/vscode_extensions.txt" || true
fi

# # Node/NPM globais
# if command -v npm >/dev/null 2>&1; then
#   npm list -g --depth=0 > "$META_DIR/npm_global_list.txt" || true
# fi
# if command -v nvm >/dev/null 2>&1; then
#   nvm list > "$META_DIR/nvm_list.txt" || true
# fi
# if command -v pnpm >/dev/null 2>&1; then
#   pnpm list -g --depth=0 > "$META_DIR/pnpm_global_list.txt" || true
# fi
# if command -v yarn >/dev/null 2>&1; then
#   yarn global list --depth=0 > "$META_DIR/yarn_global_list.txt" || true
# fi

# # Python
# if command -v pyenv >/dev/null 2>&1; then
#   pyenv versions > "$META_DIR/pyenv_versions.txt" || true
# fi
# if command -v pipx >/dev/null 2>&1; then
#   pipx list > "$META_DIR/pipx_list.txt" || true
# fi

# # Conda (se usar)
# if command -v conda >/dev/null 2>&1; then
#   conda env list > "$META_DIR/conda_envs.txt" || true
#   # Exporta cada env para YAML
#   while read -r envname; do
#     [[ "$envname" == "base" || "$envname" =~ ^[a-zA-Z0-9._-]+$ ]] || continue
#     echo "Exportando Conda env: $envname"
#     conda env export -n "$envname" > "$META_DIR/conda_env_${envname}.yml" || true
#   done < <(conda env list | awk 'NR>2 {print $1}')
# fi

# # Pip (lista global do Python atual)
# if command -v python3 >/dev/null 2>&1; then
#   python3 -m pip freeze > "$META_DIR/pip_global_freeze.txt" || true
# fi

# # Docker
# if command -v docker >/dev/null 2>&1; then
#   docker images > "$META_DIR/docker_images.txt" || true
#   docker ps -a   > "$META_DIR/docker_containers.txt" || true
#   docker volume ls > "$META_DIR/docker_volumes.txt" || true
# fi

# # Crontab
# (crontab -l || true) > "$META_DIR/crontab.txt" || true

echo

### 4) Compactação dos itens de configuração críticos (opcional, mas recomendado)
echo "==> [4/7] Compactando configurações sensíveis em tar.gz"
TAR_NAME="configs_criticos_${DATE_TAG}.tar.gz"
tar -czf "$BACKUP_ROOT/$TAR_NAME" \
  -C "$HOME" \
  .ssh \
  .gnupg \
  .zshrc \
  .zprofile \
  .zshenv \
  .bash_profile \
  .bashrc \
  Library/Preferences \
  Library/Keychains \
  Library/Fonts \
  Library/LaunchAgents \
  2>/dev/null || true

if [[ -f "$BACKUP_ROOT/$TAR_NAME" ]]; then
  shasum -a 256 "$BACKUP_ROOT/$TAR_NAME" > "$BACKUP_ROOT/$TAR_NAME.sha256"
fi
echo

### 5) Sumário de espaço usado
echo "==> [5/7] Sumário de tamanho do backup"
du -sh "$BACKUP_ROOT" || true
echo

### 6) Instruções de restauração
echo "==> [6/7] Gerando README com instruções de restauração"
cat > "$BACKUP_ROOT/README_RESTAURACAO.md" <<'EOF'
# Restauração após instalação limpa do macOS Tahoe

## 1) Apps via Homebrew e App Store
- Instale o Homebrew (veja brew.sh) e depois:
  ```bash
  brew bundle --file ./_inventarios/Brewfile
  ```
- Para listas simples:
  ```bash
  brew install $(cat ./_inventarios/brew_formulas.txt)
  brew install --cask $(cat ./_inventarios/brew_casks.txt)
  ```
- Mac App Store (mas):
  ```bash
  mas install $(cut -d " " -f1 ./_inventarios/apps_mas.txt)
  ```

## 2) VS Code
```bash
xargs -n1 code --install-extension < ./_inventarios/vscode_extensions.txt
```

## 3) Restaurar configs pessoais
Copie somente o que precisar, seletivamente, para manter o sistema limpo:
```bash
cp -R "./Library/Application Support/"* "$HOME/Library/Application Support/"
cp -R "./Library/Preferences/"* "$HOME/Library/Preferences/"
cp -R "./Library/Fonts/"* "$HOME/Library/Fonts/"
cp -R "./Library/LaunchAgents/"* "$HOME/Library/LaunchAgents/"
cp -R "./.ssh" "$HOME/"
cp "./.zshrc" "$HOME/"
cp "./.zprofile" "$HOME/"
```
> Dica: importe chaves GPG/SSH e certificados com cuidado; revalide permissões:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```

## 4) Navegadores
- Chrome/Brave/Firefox: importe perfis/senhas conforme seu provedor (iCloud/1Password/etc.).

## 5) Docker
- Recrie containers com `docker compose` ou re-pull de imagens listadas em `./_inventarios/docker_images.txt`.
- Volumes podem ser recriados a partir do orquestrador do seu projeto.

## 6) Conda, NPM, Pip, etc.
- Conda: recrie envs a partir dos YAMLs em `./_inventarios/conda_env_*.yml`:
  ```bash
  conda env create -f ./_inventarios/conda_env_meuenv.yml
  ```
- NPM global:
  ```bash
  cat ./_inventarios/npm_global_list.txt
  ```
- Pip global:
  ```bash
  pip install -r ./_inventarios/pip_global_freeze.txt
  ```

## 7) Verificação de integridade (se usar o tar.gz)
```bash
shasum -a 256 -c configs_criticos_*.sha256
```
EOF
echo

### 7) Finalização
echo "==> [7/7] Backup concluído com sucesso!"
echo "Local do backup: $BACKUP_ROOT"
echo "Revise o README_RESTAURACAO.md para restaurar seletivamente após a instalação limpa."

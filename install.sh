#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# install.sh — recrea symlinks desde ~/dotfiles a sus destinos
# ═══════════════════════════════════════════════════════════
#
# Uso:
#   cd ~/dotfiles && ./install.sh
#
# Qué hace:
#   1. Verifica que setup-identity.sh fue corrido (existe gitconfig)
#   2. Asegura que los directorios destino existan
#   3. Crea symlinks desde los archivos en ~/dotfiles a sus
#      ubicaciones esperadas por las apps
#   4. No sobrescribe archivos existentes sin avisar (hace backup)
#
# Seguridad:
#   - Si un destino ya existe y NO es un symlink, lo respalda
#     con timestamp antes de reemplazar.
#   - Nunca toca ~/.ssh/id_ed25519 (tu llave privada).

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# Verificar que estamos en el directorio correcto
if [ "$(pwd)" != "$DOTFILES_DIR" ]; then
  echo "❌ Error: correr desde $DOTFILES_DIR"
  echo "   Uso: cd ~/dotfiles && ./install.sh"
  exit 1
fi

# Verificar que setup-identity.sh fue corrido
if [ ! -f "$DOTFILES_DIR/git/gitconfig" ]; then
  echo "❌ No existe $DOTFILES_DIR/git/gitconfig"
  echo ""
  echo "   Antes de install, configurá tu identidad:"
  echo "     ./setup-identity.sh"
  echo ""
  exit 1
fi

# Asegurar que los directorios destino existen
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config"

# Función helper: crea symlink con chequeo de conflictos
link() {
  local src="$1"
  local dst="$2"

  # Si el destino ya es un symlink apuntando al src, no hacer nada
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "  ✓ $dst → $src (ya existe)"
    return 0
  fi

  # Si el destino existe (archivo real o symlink distinto), backup + reemplazar
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "  ⚠️  $dst existe, moviendo a $backup"
    mv "$dst" "$backup"
  fi

  ln -s "$src" "$dst"
  echo "  ✓ $dst → $src (creado)"
}

echo "🔗 Creando symlinks desde $DOTFILES_DIR"
echo ""

link "$DOTFILES_DIR/zsh/zshrc"              "$HOME/.zshrc"
link "$DOTFILES_DIR/git/gitconfig"          "$HOME/.gitconfig"
link "$DOTFILES_DIR/ssh/config"             "$HOME/.ssh/config"
link "$DOTFILES_DIR/ghostty/config"         "$HOME/.config/ghostty/config"
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

echo ""
echo "✅ Install completo"
echo ""
echo "Próximos pasos manuales (no automatizados):"
echo "  1. Si todavía no instalaste Homebrew:"
echo "       /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
echo "  2. Instalar paquetes:"
echo "       brew bundle --file=$DOTFILES_DIR/Brewfile"
echo "  3. Si todavía no generaste SSH key:"
echo "       ssh-keygen -t ed25519 -C \"tu@email.com\""
echo "  4. Subir llave a GitHub (auth + signing):"
echo "       gh auth login"
echo "       gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication"
echo "       gh ssh-key add ~/.ssh/id_ed25519.pub --type signing"
echo "  5. Cargar llave al ssh-agent (passphrase a Keychain):"
echo "       ssh-add --apple-use-keychain ~/.ssh/id_ed25519"
echo "  6. Reiniciar terminal y disfrutar 🚀"
echo ""

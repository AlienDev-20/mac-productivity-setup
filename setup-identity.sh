#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# setup-identity.sh — genera gitconfig y allowed_signers con TU identidad
# ═══════════════════════════════════════════════════════════
#
# Uso:
#   cd ~/dotfiles && ./setup-identity.sh
#
# Qué hace:
#   1. Te pide nombre + email
#   2. Genera ~/dotfiles/git/gitconfig (desde gitconfig.template)
#   3. Genera ~/.ssh/allowed_signers (para verificación local de commits)
#
# Tenés que correrlo ANTES de install.sh.
#
# Re-correrlo:
#   Si cambiás de email o nombre, podés correrlo de nuevo. Sobreescribe
#   el gitconfig generado.

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
TEMPLATE="$DOTFILES_DIR/git/gitconfig.template"
GITCONFIG_OUT="$DOTFILES_DIR/git/gitconfig"
PUB_KEY="$HOME/.ssh/id_ed25519.pub"
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"

# Verificar que estamos en el directorio correcto
if [ "$(pwd)" != "$DOTFILES_DIR" ]; then
  echo "❌ Error: correr desde $DOTFILES_DIR"
  echo "   Uso: cd ~/dotfiles && ./setup-identity.sh"
  exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "❌ No se encontró el template: $TEMPLATE"
  exit 1
fi

echo "═══════════════════════════════════════════════════════════"
echo "  Setup de identidad para Git + SSH signing"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Pedir identidad
read -r -p "Tu nombre (ej: Juan Perez): " NAME
if [ -z "$NAME" ]; then
  echo "❌ Nombre vacío. Abortando."
  exit 1
fi

read -r -p "Tu email (ej: juan@example.com): " EMAIL
if [ -z "$EMAIL" ]; then
  echo "❌ Email vacío. Abortando."
  exit 1
fi

echo ""
echo "→ Generando $GITCONFIG_OUT..."

# Generar gitconfig desde template
# Usamos sd si está, sino sed
if command -v sd >/dev/null 2>&1; then
  sd '\{\{NAME\}\}' "$NAME" < "$TEMPLATE" \
    | sd '\{\{EMAIL\}\}' "$EMAIL" \
    | sd '\{\{HOME\}\}' "$HOME" \
    > "$GITCONFIG_OUT"
else
  sed -e "s|{{NAME}}|$NAME|g" \
      -e "s|{{EMAIL}}|$EMAIL|g" \
      -e "s|{{HOME}}|$HOME|g" \
      "$TEMPLATE" > "$GITCONFIG_OUT"
fi

echo "  ✓ $GITCONFIG_OUT"
echo ""

# Generar allowed_signers (requiere que la SSH key exista)
echo "→ Generando $ALLOWED_SIGNERS..."

if [ ! -f "$PUB_KEY" ]; then
  echo "  ⚠️  No existe $PUB_KEY"
  echo "     Generá la SSH key primero con:"
  echo "       ssh-keygen -t ed25519 -C \"$EMAIL\""
  echo "     Después corré este script de nuevo."
  echo ""
  echo "  (Por ahora se saltea allowed_signers — git va a firmar OK"
  echo "   pero la verificación local con --show-signature no va a andar)"
else
  mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
  PUB_KEY_CONTENT=$(cat "$PUB_KEY")
  echo "$EMAIL $PUB_KEY_CONTENT" > "$ALLOWED_SIGNERS"
  chmod 600 "$ALLOWED_SIGNERS"
  echo "  ✓ $ALLOWED_SIGNERS"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  ✅ Identidad configurada"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  Nombre:   $NAME"
echo "  Email:    $EMAIL"
echo "  Signing:  $PUB_KEY"
echo ""
echo "  Próximo paso:"
echo "    ./install.sh"
echo ""

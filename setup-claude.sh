#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# setup-claude.sh — Fase 2: Claude Code + Gentle AI + herdr
# ═══════════════════════════════════════════════════════════
#
# Uso:
#   cd ~/dotfiles && ./setup-claude.sh            # instala todo
#   cd ~/dotfiles && ./setup-claude.sh --dry-run  # solo muestra qué haría
#
# Qué hace (en orden):
#   1. Instala node, jq, gentle-ai y herdr (Brewfile.claude)
#   2. Instala Claude Code con su installer oficial (si falta)
#   3. Corre `gentle-ai install` para Claude Code con el preset del
#      equipo (persona Gentleman, Engram, skills, context7, permisos)
#   4. Instala CodeGraph (índice de código) y lo conecta a Claude Code
#   5. Fusiona claude/settings.team.json en ~/.claude/settings.json
#      (estilo Gentleman, idioma, lista de archivos prohibidos,
#      notificaciones de macOS). Estilo e idioma del equipo ganan;
#      los permisos se unen y los hooks solo se agregan. Backup antes.
#   6. Verifica que todo quedó instalado
#
# Pre-requisito: haber corrido la Fase 1 (README, pasos 1 a 8).
# Es idempotente: podés correrlo de nuevo sin romper nada.

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
DRY_RUN=0
CLAUDE_INSTALL_URL="https://claude.ai/install.sh"
CODEGRAPH_PKG="@colbymchenry/codegraph"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) sed -n '3,24p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "❌ Argumento desconocido: $arg"; exit 1 ;;
  esac
done

if [ "$(pwd)" != "$DOTFILES_DIR" ]; then
  echo "❌ Error: correr desde $DOTFILES_DIR"
  echo "   Uso: cd ~/dotfiles && ./setup-claude.sh"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ No está Homebrew. Primero completá la Fase 1 (README, paso 1)."
  exit 1
fi

# Ejecuta un comando, o solo lo imprime en --dry-run
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

step() { echo ""; echo "━━ $* ━━"; }

# ───────────────────────────────────────────────────────────
step "1/6 Paquetes: node, jq, gentle-ai, herdr"
run brew bundle --file="$DOTFILES_DIR/Brewfile.claude"

# ───────────────────────────────────────────────────────────
step "2/6 Claude Code"
# El installer deja el binario en ~/.local/bin (ya está en el PATH del zshrc)
export PATH="$HOME/.local/bin:$PATH"
if command -v claude >/dev/null 2>&1; then
  echo "  ✓ Claude Code ya instalado: $(claude --version 2>/dev/null || echo '?')"
else
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  [dry-run] curl -fsSL $CLAUDE_INSTALL_URL | bash"
  else
    curl -fsSL "$CLAUDE_INSTALL_URL" | bash
    hash -r
    command -v claude >/dev/null 2>&1 || {
      echo "❌ El installer terminó pero no encuentro 'claude' en el PATH."
      echo "   Abrí una terminal nueva y volvé a correr este script."
      exit 1
    }
    echo "  ✓ Claude Code instalado: $(claude --version)"
  fi
fi

# ───────────────────────────────────────────────────────────
step "3/6 Gentle AI → Claude Code (preset del equipo)"
# Instala en ~/.claude: CLAUDE.md con el orquestador y ODD, persona
# Gentleman (output style), skills, Engram (memoria persistente),
# context7 (docs al día) y la lista de permisos. Es no interactivo.
GENTLE_FLAGS=(install --agent claude-code --preset full-gentleman --persona gentleman --scope global)
if [ "$DRY_RUN" -eq 1 ]; then
  if command -v gentle-ai >/dev/null 2>&1; then
    gentle-ai "${GENTLE_FLAGS[@]}" --dry-run
  else
    echo "  [dry-run] gentle-ai ${GENTLE_FLAGS[*]}"
  fi
else
  gentle-ai "${GENTLE_FLAGS[@]}"
fi

# ───────────────────────────────────────────────────────────
step "4/6 CodeGraph (índice de código para Claude)"
if command -v codegraph >/dev/null 2>&1; then
  echo "  ✓ codegraph ya instalado: $(codegraph --version 2>/dev/null || echo '?')"
else
  run npm install -g "$CODEGRAPH_PKG"
fi
# Registra el MCP server + hook en Claude Code, global, sin preguntar.
# Si ~/.claude.json ya tiene el server, no hace falta repetirlo.
if [ -f "$HOME/.claude.json" ] && jq -e '.mcpServers.codegraph' "$HOME/.claude.json" >/dev/null 2>&1; then
  echo "  ✓ codegraph ya conectado a Claude Code"
else
  run codegraph install --yes
fi

# ───────────────────────────────────────────────────────────
step "5/6 Settings del equipo → ~/.claude/settings.json"
SETTINGS="$HOME/.claude/settings.json"
TEAM="$DOTFILES_DIR/claude/settings.team.json"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "  [dry-run] fusionar $TEAM en $SETTINGS"
else
  mkdir -p "$HOME/.claude"
  [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
  # Reglas de fusión:
  #   - outputStyle / language: el valor del equipo gana
  #   - permissions.deny: unión, sin duplicados, respetando tu orden
  #   - hooks: se agregan solo los que no existan (por comando)
  jq --slurpfile t "$TEAM" '
    . as $cur | $t[0] as $team
    | .outputStyle = $team.outputStyle
    | .language = $team.language
    | .permissions.deny = (((.permissions.deny) // []) + $team.permissions.deny
        | reduce .[] as $x ([]; if index($x) then . else . + [$x] end))
    | reduce ($team.hooks | to_entries[]) as $h (.;
        .hooks[$h.key] = (
          (.hooks[$h.key] // []) + [
            $h.value[] | . as $e
            | select(
                (($cur.hooks[$h.key] // []) | [.[].hooks[]?.command] | index($e.hooks[0].command)) == null
              )
          ]
        )
      )
  ' "$SETTINGS" > "$SETTINGS.tmp"
  if cmp -s "$SETTINGS" "$SETTINGS.tmp"; then
    rm "$SETTINGS.tmp"
    echo "  ✓ settings.json ya tenía todo lo del equipo (sin cambios)"
  else
    cp "$SETTINGS" "$SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$SETTINGS.tmp" "$SETTINGS"
    echo "  ✓ settings.json fusionado (backup al lado con timestamp)"
  fi
fi

# ───────────────────────────────────────────────────────────
step "6/6 Verificación"
check() {
  local name="$1"; shift
  if [ "$DRY_RUN" -eq 1 ]; then echo "  [dry-run] verificar $name"; return 0; fi
  if out=$("$@" 2>/dev/null); then
    echo "  ✓ $name → ${out%%$'\n'*}"
  else
    echo "  ✗ $name no responde"; FAILED=1
  fi
}
FAILED=0
check "claude"     claude --version
check "gentle-ai"  gentle-ai --version
check "engram"     engram --version
check "codegraph"  codegraph --version
check "herdr"      herdr --version
check "herramientas gentle-ai" gentle-ai review mode status

if [ "$FAILED" -ne 0 ]; then
  echo ""
  echo "⚠️  Algo no quedó bien. Abrí una terminal nueva y corré de nuevo ./setup-claude.sh"
  exit 1
fi

echo ""
echo "✅ Fase 2 completa"
echo ""
echo "Próximos pasos (una sola vez):"
echo "  1. Abrí una terminal NUEVA (para que tome el PATH)"
echo "  2. Entrá a una carpeta de proyecto y corré:"
echo "       claude"
echo "     La primera vez te pide iniciar sesión en el navegador."
echo "  3. Para trabajar con varios agentes a la vez:"
echo "       herdr"
echo ""
echo "Mirá la sección 'Fase 2' del README para el día a día."

#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# share-android.sh — espeja un Android en una ventana capturable por OBS
# ═══════════════════════════════════════════════════════════
#
# Uso:
#   ./share-android.sh                              # USB, un solo device
#   ./share-android.sh --wireless 192.168.0.42:5555 # sin cable
#   ./share-android.sh --serial ABC123              # varios devices conectados
#   ./share-android.sh --view-only                  # no inyecta mouse/teclado
#   ./share-android.sh --with-audio                 # audio del device (Android 11+)
#
# Por qué existe:
#   scrcpy abre una ventana local y OBS la captura con Window Capture.
#   El título es fijo ("Android OBS") para que la fuente de OBS quede
#   bindeada por nombre y no se rompa cuando el device se reconecta.
#
# Requisitos (vienen en el Brewfile):
#   brew install scrcpy
#   brew install --cask android-platform-tools   # adb

set -euo pipefail

WINDOW_TITLE="Android OBS"
MAX_SIZE="${MAX_SIZE:-1080}"
MAX_FPS="${MAX_FPS:-60}"

WIRELESS=""
SERIAL=""
VIEW_ONLY=0
WITH_AUDIO=0

usage() {
  cat <<'EOF'
share-android.sh — espeja Android en una ventana para capturar en OBS

Uso:
  ./share-android.sh [opciones]

Opciones:
  --wireless <host:puerto>  Conectar inalámbrico (default de Android: <ip>:5555)
  --serial <serial>         Elegir device cuando hay más de uno (adb devices)
  --view-only               Modo espectador: no inyecta mouse/teclado en el celu
  --with-audio              Forward de audio del device (requiere Android 11+)
  -h, --help                Esta ayuda

Variables de entorno:
  MAX_SIZE  Resolución máxima del lado más largo (default 1080)
  MAX_FPS   FPS máximos (default 60)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --wireless)
      [[ $# -ge 2 ]] || { echo "❌ --wireless necesita host:puerto"; exit 1; }
      WIRELESS="$2"; shift 2 ;;
    --serial)
      [[ $# -ge 2 ]] || { echo "❌ --serial necesita un valor"; exit 1; }
      SERIAL="$2"; shift 2 ;;
    --view-only) VIEW_ONLY=1; shift ;;
    --with-audio) WITH_AUDIO=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "❌ Opción desconocida: $1"
      echo ""
      usage
      exit 1 ;;
  esac
done

command -v scrcpy >/dev/null 2>&1 || {
  echo "❌ scrcpy no está instalado."
  echo "   Corré: brew install scrcpy"
  exit 1
}

command -v adb >/dev/null 2>&1 || {
  echo "❌ adb no está en el PATH."
  echo "   Corré: brew install --cask android-platform-tools"
  exit 1
}

if [[ -n "$WIRELESS" ]]; then
  echo "📶 Conectando a $WIRELESS ..."
  if ! adb connect "$WIRELESS" >/dev/null 2>&1; then
    echo "❌ No pude conectar a $WIRELESS"
    echo "   Primera vez: emparejá con 'adb pair <ip>:<puerto>' — el puerto y el"
    echo "   código salen en Opciones de desarrollador → Depuración inalámbrica."
    exit 1
  fi
fi

device_count=$(adb devices | awk 'NR > 1 && $2 == "device"' | wc -l | tr -d ' ')

if [[ "$device_count" -eq 0 ]]; then
  echo "❌ No hay ningún Android autorizado."
  echo ""
  echo "   Checklist:"
  echo "   1. Conectá el celu por USB"
  echo "   2. Desbloqueá la pantalla"
  echo "   3. Aceptá el popup '¿Permitir depuración USB?'"
  echo "   4. Verificá: adb devices"
  exit 1
fi

if [[ "$device_count" -gt 1 && -z "$SERIAL" ]]; then
  echo "⚠️  Hay $device_count devices conectados. Elegí uno con --serial:"
  adb devices | awk 'NR > 1 && $2 == "device" {printf "     %s\n", $1}'
  exit 1
fi

ARGS=(
  "--window-title=$WINDOW_TITLE"
  "--max-size=$MAX_SIZE"
  "--max-fps=$MAX_FPS"
  "--stay-awake"
)

[[ "$VIEW_ONLY" -eq 1 ]] && ARGS+=("--no-control")
[[ "$WITH_AUDIO" -eq 0 ]] && ARGS+=("--no-audio")
[[ -n "$SERIAL" ]] && ARGS+=("--serial=$SERIAL")

echo "📱 Espejando '$WINDOW_TITLE'"
echo "   En OBS: Sources → Window Capture → '$WINDOW_TITLE'"
echo "   Ctrl+C para cortar."
exec scrcpy "${ARGS[@]}"

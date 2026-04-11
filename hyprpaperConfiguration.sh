#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_REL="pictures/trenza.png"
FIT_MODE="cover"
SPLASH="false"

# Archivo de salida (por usuario)
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
CONF_FILE="$CONF_DIR/hyprpaper.conf"

WALLPAPER_PATH="$HOME/$WALLPAPER_REL"

if [[ ! -f "$WALLPAPER_PATH" ]]; then
  echo "No existe el wallpaper: $WALLPAPER_PATH" >&2
  exit 1
fi

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl no está disponible. ¿Estás corriendo Hyprland?" >&2
  exit 1
fi

mapfile -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')

if [[ ${#MONITORS[@]} -eq 0 ]]; then
  echo "No se detectaron monitores con hyprctl." >&2
  exit 1
fi

mkdir -p "$CONF_DIR"

{
  echo "splash = $SPLASH"
  echo
  for m in "${MONITORS[@]}"; do
    cat <<EOF
wallpaper {
  monitor = $m
  path = $WALLPAPER_PATH
  fit_mode = $FIT_MODE
}

EOF
  done
} > "$CONF_FILE"

echo "Generado: $CONF_FILE"
echo "Monitores: ${MONITORS[*]}"

if pgrep -x hyprpaper >/dev/null 2>&1; then
  pkill -x hyprpaper || true
  nohup hyprpaper >/dev/null 2>&1 &
  echo "hyprpaper reiniciado."
else
  echo "Inicia hyprpaper cuando quieras: hyprpaper"
fi
#!/bin/bash
set -e

# --- Colores para la salida ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando copia de seguridad de configuraciones ---${NC}"

CONFIGS=(
    "/etc/pacman.conf:root/etc"

    "/usr/share/sddm/themes/sugar-dark:root/sddm"
    "/etc/sddm.conf.d:root/sddm"

    "$HOME/.config/hypr/hyprland.conf:configs/hyprland"
    "$HOME/.config/hypr/animations.conf:configs/hyprland"
    "$HOME/.config/hypr/autostart.conf:configs/hyprland"
    "$HOME/.config/hypr/windows.conf:configs/hyprland"
    "$HOME/.config/hypr/windowrules.conf:configs/hyprland"
    "$HOME/.config/hypr/keybinds.conf:configs/hyprland"
    "$HOME/.config/hypr/hyprlock.conf:configs/hyprland"
    "$HOME/.config/hypr/hyprpaper.conf:configs/hyprland"
    "$HOME/pictures:wallpapers"

    "$HOME/.config/waybar/config.jsonc:configs/waybar"
    "$HOME/.config/waybar/style.css:configs/waybar"

    "$HOME/.config/alacritty/alacritty.toml:configs/alacritty"

    "$HOME/.config/rofi/config.rasi:configs/rofi"
)

for entry in "${CONFIGS[@]}"; do
    ORIGEN="${entry%%:*}"
    DESTINO_DIR="${entry##*:}"

    mkdir -p "$DESTINO_DIR"

    echo "Copiando $(basename "$ORIGEN") a $DESTINO_DIR..."

    if [ -d "$ORIGEN" ]; then
        cp -av "$ORIGEN" "$DESTINO_DIR/"
    else
        cp -v "$ORIGEN" "$DESTINO_DIR/"
    fi
done

echo -e "\n${GREEN}¡Copia de seguridad local completada!${NC}"

if [ -d ".git" ]; then
    echo -e "\n${GREEN}--- Subiendo cambios a GitHub ---${NC}"

    echo -e "\nArchivos que se agregarán al commit:"
    git add -v . || { echo -e "${YELLOW}Error al agregar archivos.${NC}"; exit 1; }

    if git diff --staged --quiet; then
        echo -e "\n${YELLOW}No hay cambios que subir. ¡Tu repositorio ya está actualizado!${NC}"
    else
        COMMIT_MESSAGE="Actualización de configuraciones $(date +'%Y-%m-%d %H:%M:%S')"
        git commit -m "$COMMIT_MESSAGE"
        echo -e "${GREEN}Commit creado: $COMMIT_MESSAGE${NC}"

        git push || { echo -e "${YELLOW}Error al hacer push. Revisa tu conexión o configuración de Git.${NC}"; exit 1; }
        echo -e "\n${GREEN}¡Cambios subidos a GitHub exitosamente!${NC}"
    fi
else
    echo -e "\n${YELLOW}AVISO: Esta carpeta no es un repositorio de Git.${NC}"
    echo "Para poder subir los cambios, primero inicializa Git y conéctalo a GitHub."
fi
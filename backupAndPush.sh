#!/bin/bash
# Evitamos usar 'set -e' de forma global para poder manejar los errores de copia nosotros mismos

# --- Colores para la salida ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}--- Iniciando copia de seguridad de configuraciones ---${NC}"

# ==============================================================================
# 🛠️ ZONA DE CONFIGURACIÓN 🛠️
# Modifica esta lista con los archivos o carpetas que quieras respaldar.
# Formato: "/ruta/original/en/tu/pc:carpeta/destino/en/el/repo"
# ==============================================================================
CONFIGS=(
    # Ejemplos de sistema
    "/etc/pacman.conf:root/etc"
    "/usr/share/sddm/themes/sugar-dark:root/sddm"
    "/etc/sddm.conf.d:root/sddm"

    # Entorno de escritorio (Ejemplo: Hyprland)
    "$HOME/.config/hypr/hyprland.conf:configs/hypr"
    "$HOME/.config/hypr/animations.conf:configs/hypr"
    "$HOME/.config/hypr/autostart.conf:configs/hypr"
    "$HOME/.config/hypr/windows.conf:configs/hypr"
    "$HOME/.config/hypr/windowrules.conf:configs/hypr"
    "$HOME/.config/hypr/keybinds.conf:configs/hypr"
    "$HOME/.config/hypr/hyprlock.conf:configs/hypr"
    
    # Fondos de pantalla
    "$HOME/wallpaper:wallpapers"

    # Barra de estado y terminal
    "$HOME/.config/waybar/config.jsonc:configs/waybar"
    "$HOME/.config/waybar/style.css:configs/waybar"
    "$HOME/.config/kitty/kitty.conf:configs/kitty"
    "$HOME/.config/kitty/theme.conf:configs/kitty" 
    "$HOME/.config/fastfetch/config.jsonc:configs/fastfetch"
    "$HOME/.bashrc:home_files"

    # Lanzador de aplicaciones
    "$HOME/.config/rofi/config.rasi:configs/rofi"
)
# ==============================================================================

for entry in "${CONFIGS[@]}"; do
    ORIGEN="${entry%%:*}"
    DESTINO_DIR="${entry##*:}"

    # Verificamos si el archivo o directorio de origen realmente existe
    if [ ! -e "$ORIGEN" ]; then
        echo -e "${RED}Omitiendo: ${YELLOW}$ORIGEN${RED} (No existe en este sistema)${NC}"
        continue
    fi

    mkdir -p "$DESTINO_DIR"
    echo -e "Copiando ${GREEN}$(basename "$ORIGEN")${NC} a $DESTINO_DIR..."

    # Copiamos dependiendo de si es un directorio o un archivo
    if [ -d "$ORIGEN" ]; then
        cp -av "$ORIGEN/"* "$DESTINO_DIR/" 2>/dev/null || echo -e "${YELLOW}Advertencia: Algunos archivos en $ORIGEN requieren permisos root.${NC}"
    else
        cp -v "$ORIGEN" "$DESTINO_DIR/" 2>/dev/null || echo -e "${YELLOW}Advertencia: No se pudo copiar $ORIGEN (¿Faltan permisos?).${NC}"
    fi
done

echo -e "\n${GREEN}¡Copia de seguridad local completada!${NC}"

# --- Sección de GitHub (Totalmente genérica) ---
if [ -d ".git" ]; then
    echo -e "\n${GREEN}--- Subiendo cambios a GitHub ---${NC}"

    echo -e "Archivos que se agregarán al commit:"
    git add -v . || { echo -e "${RED}Error al agregar archivos.${NC}"; exit 1; }

    if git diff --staged --quiet; then
        echo -e "\n${YELLOW}No hay cambios que subir. ¡Tu repositorio ya está actualizado!${NC}"
    else
        COMMIT_MESSAGE="Actualización de configuraciones $(date +'%Y-%m-%d %H:%M:%S')"
        git commit -m "$COMMIT_MESSAGE"
        echo -e "${GREEN}Commit creado: $COMMIT_MESSAGE${NC}"

        # Subirá a la rama actual y al repositorio remoto (origin) configurado
        git push || { echo -e "${RED}Error al hacer push. Revisa tu conexión, permisos o configuración de Git.${NC}"; exit 1; }
        echo -e "\n${GREEN}¡Cambios subidos a GitHub exitosamente!${NC}"
    fi
else
    echo -e "\n${YELLOW}AVISO: Esta carpeta no es un repositorio de Git.${NC}"
    echo "Para poder subir los cambios, primero inicializa Git en esta carpeta:"
    echo "  1. git init"
    echo "  2. git remote add origin https://github.com/TU_USUARIO/TU_REPO.git"
    echo "  3. git branch -M main"
    echo "Y vuelve a ejecutar el script."
fi
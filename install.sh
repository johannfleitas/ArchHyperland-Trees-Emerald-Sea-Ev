#!/bin/bash

set -e

echo "Actualizando el sistema e instalando paquetes necesarios..."

# Obtener ruta real del script y BASE_DIR de configs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/configs"
CONFIG_DEST="$HOME/.config"

echo "Usando BASE_DIR = $BASE_DIR"
echo "Instalando configuraciones en $CONFIG_DEST"

# 1. Paquetes
sudo pacman -Rns --noconfirm kitty-shell-integration kitty-terminfo wofi 2>/dev/null || true
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm hyprland waybar alacritty starship

# 2. Configs a ~/.config
CONFIG_DIRS=("hypr" "waybar" "alacritty" "rofi")

for dir in "${CONFIG_DIRS[@]}"; do
    SRC="$BASE_DIR/$dir"      # configs/hypr, configs/waybar, etc.
    DST="$CONFIG_DEST/$dir"   # ~/.config/hypr, ~/.config/waybar, etc.

    # Siempre creamos la carpeta destino (por si la app no la crea sola)
    mkdir -p "$DST"

    if [ -d "$SRC" ]; then
        if [ "$(ls -A "$SRC")" ]; then
            # Si quieres respetar cambios locales, deja -ru. Si quieres forzar, cambia a -r
            cp -ru "$SRC/"* "$DST/"
            echo "Copiado: $SRC --> $DST"
        else
            echo "La carpeta $SRC está vacía, omitiendo copia..."
        fi
    else
        echo "ADVERTENCIA: No existe $SRC en el repo, no hay configs propias para '$dir'."
    fi
done

# 3. Extras a /etc
EXTRA_SRC=( "etc" )
EXTRA_DST=( "/etc" )

for i in "${!EXTRA_SRC[@]}"; do
    SRC="$BASE_DIR/${EXTRA_SRC[i]}"   # configs/etc
    DST="${EXTRA_DST[i]}"             # /etc

    if [ -d "$SRC" ]; then
        if [ "$(ls -A "$SRC")" ]; then
            echo "Copiando $SRC --> $DST (requiere permisos de superusuario)"
            sudo cp -ru "$SRC/"* "$DST/"
            echo "Copiado: $SRC --> $DST"
        else
            echo "La carpeta $SRC está vacía, omitiendo copia..."
        fi
    else
        echo "ADVERTENCIA: No existe $SRC en el repo, no se copia nada a $DST."
    fi
done

echo "Instalación y copia de configuraciones completada."
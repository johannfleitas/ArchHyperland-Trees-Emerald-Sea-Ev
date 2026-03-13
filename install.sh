#!/bin/bash

set -e

echo "Actualizando el sistema e instalando paquetes necesarios..."

# Obtener ruta real del script y BASE_DIR de configs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/configs"
CONFIG_DEST="$HOME/.config"

echo "Usando BASE_DIR = $BASE_DIR"
echo "Instalando configuraciones en $CONFIG_DEST"


sudo pacman -Rns --noconfirm kitty-shell-integration kitty-terminfo wofi 2>/dev/null || true
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm hyprland waybar alacritty starship git base-devel

if ! command -v yay >/dev/null 2>&1; then
    echo "yay no está instalado, instalando yay desde AUR..."

    YAY_DIR="$HOME/.cache/yay-install"
    rm -rf "$YAY_DIR"
    mkdir -p "$YAY_DIR"

    git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
    cd "$YAY_DIR"
    makepkg -si --noconfirm

    cd "$SCRIPT_DIR"
    echo "yay instalado correctamente."
else
    echo "yay ya está instalado, omitiendo instalación."
fi

HELIUM_PKG="helium-browser-bin"

echo "Instalando navegador $HELIUM_PKG con yay..."
yay -S --needed --noconfirm "$HELIUM_PKG" || {
    echo "ADVERTENCIA: No se pudo instalar el paquete '$HELIUM_PKG' con yay."
}

CONFIG_DIRS=("hypr" "waybar" "alacritty" "rofi")

for dir in "${CONFIG_DIRS[@]}"; do
    SRC="$BASE_DIR/$dir"      # configs/hypr, configs/waybar, etc.
    DST="$CONFIG_DEST/$dir"   # ~/.config/hypr, ~/.config/waybar, etc.

    mkdir -p "$DST"

    if [ -d "$SRC" ]; then
        if [ "$(ls -A "$SRC")" ]; then
            cp -ru "$SRC/"* "$DST/"
            echo "Copiado: $SRC --> $DST"
        else
            echo "La carpeta $SRC está vacía, omitiendo copia..."
        fi
    else
        echo "ADVERTENCIA: No existe $SRC en el repo, no hay configs propias para '$dir'."
    fi
done

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

echo "Instalación de paquetes y copia de configuraciones completada."
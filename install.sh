#!/bin/bash
set -euo pipefail
 
echo "Actualizando el sistema e instalando paquetes necesarios..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/configs"
REAL_HOME="$(eval echo ~"${SUDO_USER:-$USER}")"
CONFIG_DEST="$REAL_HOME/.config"

echo "Usando BASE_DIR = $BASE_DIR"
echo "Instalando configuraciones en $CONFIG_DEST"

PACMAN_APPS_UNINSTALL=(wofi)

PACMAN_APPS_INSTALL=(alacritty waybar starship rofi hyprpaper obsidian 
                    pavucontrol polkit-kde-agent power-profiles-daemon 
                    brightnessctl unrar unzip firefox network-manager-applet
                    debugedit fakeroot base-devel git)

YAY_APPS=(helium-browser-bin eww)

CONFIG_DIRS=(hyprland waybar alacritty rofi)


to_remove=()
for pkg in "${PACMAN_APPS_UNINSTALL[@]}"; do
  if pacman -Qi "$pkg" >/dev/null 2>&1; then
    to_remove+=("$pkg")
  fi
done

if ((${#to_remove[@]})); then
  sudo pacman -Rns --noconfirm "${to_remove[@]}"
else
  echo "Nada para desinstalar (paquetes no instalados)."
fi

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm "${PACMAN_APPS_INSTALL[@]}"

if ! command -v yay >/dev/null 2>&1; then
  echo "yay no está instalado, instalando yay desde AUR..."
  mkdir -p "$REAL_HOME/.cache"
  YAY_DIR="$REAL_HOME/.cache/yay-install"
  rm -rf "$YAY_DIR"
  mkdir -p "$YAY_DIR"
  git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
  (cd "$YAY_DIR" && makepkg -si --noconfirm)
fi
if ((${#YAY_APPS[@]})); then
  echo "Instalando AUR con yay: ${YAY_APPS[*]}..."
  yay -S --needed --noconfirm "${YAY_APPS[@]}" || {
    echo "ADVERTENCIA: No se pudo instalar uno o más paquetes AUR."
  }
fi

mkdir -p "$CONFIG_DEST"
for dir in "${CONFIG_DIRS[@]}"; do
  SRC="$BASE_DIR/$dir"
  DST="$CONFIG_DEST/$dir"

  if [ -d "$SRC" ]; then
    mkdir -p "$DST"
    cp -a "$SRC/." "$DST/"
    echo "Copiado: $SRC --> $DST"
  else
    echo "ADVERTENCIA: No existe $SRC en el repo, no hay configs propias para '$dir'."
  fi
done

echo "Listo."
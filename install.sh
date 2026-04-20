#!/bin/bash
set -euo pipefail
trap 'echo "ERROR en línea $LINENO: comando: $BASH_COMMAND" >&2' ERR

echo "Actualizando el sistema e instalando paquetes necesarios..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR/configs"
HOME_FILES_SRC="$SCRIPT_DIR/home_files"
REAL_HOME="$(eval echo ~"${SUDO_USER:-$USER}")"
CONFIG_DEST="$REAL_HOME/.config"
ROOT_DIR="$SCRIPT_DIR/root"
WALLPAPERS="$SCRIPT_DIR/wallpapers"
HYPERPAPER_SCRIPT="$SCRIPT_DIR/hyprpaperConfiguration.sh"
REAL_USER="${SUDO_USER:-$USER}"

echo "Usando BASE_DIR = $BASE_DIR"
echo "Instalando configuraciones en $CONFIG_DEST"

PACMAN_APPS_UNINSTALL=(wofi)
PACMAN_APPS_FILE="$SCRIPT_DIR/pacman.txt"

YAY_APPS=(helium-browser-bin)
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

if [[ ! -f "$PACMAN_APPS_FILE" ]]; then
  echo "ERROR: No existe $PACMAN_APPS_FILE"
  exit 1
fi

mapfile -t PACMAN_APPS_INSTALL < "$PACMAN_APPS_FILE"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm "${PACMAN_APPS_INSTALL[@]}"

if ! command -v yay >/dev/null 2>&1; then
  echo "yay no está instalado, instalando yay desde AUR..."
  sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.cache"
  YAY_DIR="$REAL_HOME/.cache/yay-install"
  sudo -u "$REAL_USER" rm -rf "$YAY_DIR"
  sudo -u "$REAL_USER" mkdir -p "$YAY_DIR"
  sudo -u "$REAL_USER" git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
  sudo -u "$REAL_USER" bash -lc "cd '$YAY_DIR' && makepkg -si --noconfirm"
fi

if ((${#YAY_APPS[@]})); then
  echo "Instalando AUR con yay: ${YAY_APPS[*]}..."
  sudo -u "$REAL_USER" yay -S --needed --noconfirm "${YAY_APPS[@]}" || {
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

if [[ -d "$HOME_FILES_SRC" ]]; then
  echo "Instalando archivos en la raíz de $REAL_HOME..."
  cp -a "$HOME_FILES_SRC/." "$REAL_HOME/"
  sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/."
  echo "Copiado: $HOME_FILES_SRC --> $REAL_HOME"
else
  echo "ADVERTENCIA: No existe la carpeta $HOME_FILES_SRC en el repo."
fi

echo "Instalando archivos de sistema desde $ROOT_DIR ..."

if [[ -f "$ROOT_DIR/etc/pacman.conf" ]]; then
  sudo install -Dm644 "$ROOT_DIR/etc/pacman.conf" /etc/pacman.conf
  echo "Instalado: /etc/pacman.conf"
else
  echo "ADVERTENCIA: No existe $ROOT_DIR/etc/pacman.conf"
fi

if [[ -d "$ROOT_DIR/sddm/sddm.conf.d" ]]; then
  sudo mkdir -p /etc/sddm.conf.d
  sudo cp -a "$ROOT_DIR/sddm/sddm.conf.d/." /etc/sddm.conf.d/
  echo "Instalado: /etc/sddm.conf.d/"
else
  echo "ADVERTENCIA: No existe $ROOT_DIR/sddm/sddm.conf.d"
fi

if [[ -d "$ROOT_DIR/sddm/sugar-dark" ]]; then
  sudo mkdir -p /usr/share/sddm/themes
  sudo rm -rf /usr/share/sddm/themes/sugar-dark
  sudo cp -a "$ROOT_DIR/sddm/sugar-dark" /usr/share/sddm/themes/
  echo "Instalado: /usr/share/sddm/themes/sugar-dark"
else
  echo "ADVERTENCIA: No existe $ROOT_DIR/sddm/sugar-dark"
fi

if [[ -d "$WALLPAPERS" ]]; then
  mkdir -p "$REAL_HOME"
  cp -a "$WALLPAPERS/." "$REAL_HOME/"
  sudo chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME"
  echo "Wallpapers copiados: $WALLPAPERS --> $REAL_HOME"
else
  echo "ADVERTENCIA: No existe $WALLPAPERS"
fi

if [[ -f "$HYPERPAPER_SCRIPT" ]]; then
  chmod +x "$HYPERPAPER_SCRIPT"
  bash "$HYPERPAPER_SCRIPT"
else
  echo "ADVERTENCIA: No existe $HYPERPAPER_SCRIPT"
fi

echo "Listo."
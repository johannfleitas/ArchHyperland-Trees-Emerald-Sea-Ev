#!/bin/bash

# Instalar los paquetes necesarios
echo "Actualizando el sistema e instalando paquetes necesarios..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm hyprland waybar alacritty starship

# Array de carpetas/configs para copiar a ~/.config/
CONFIG_DIRS=("hypr" "waybar" "kitty" "alacritty" "eww" "rofi")

# Arrays para carpetas/archivos a copiar/directorio de destino absoluto
EXTRA_SRC=( "etc" )           # Añade aquí el nombre como está en tu repo
EXTRA_DST=( "/etc" )          # Destino absoluto correspondiente

# Carpeta base (actual)
BASE_DIR="$(pwd)/configs"
CONFIG_DEST="$HOME/.config"

# Copiar a ~/. config/
for dir in "${CONFIG_DIRS[@]}"; do
    SRC="$BASE_DIR/$dir"
    DST="$CONFIG_DEST/$dir"
    if [ -e "$SRC" ]; then
        mkdir -p "$DST"
        # Verificar si hay archivos antes de copiar
        if [ "$(ls -A "$SRC")" ]; then
            cp -ru "$SRC/"* "$DST/"
            echo "Copiado: $SRC --> $DST"
        else
            echo "La carpeta $SRC está vacía, omitiendo copia..."
        fi
    else
        echo "No existe $SRC, creando carpeta en el repositorio..."
        mkdir -p "$SRC"
        echo "Carpeta creada: $SRC"
    fi
done

# Copiar extras (requiere sudo generalmente)
for i in "${!EXTRA_SRC[@]}"; do
    SRC="$BASE_DIR/${EXTRA_SRC[i]}"
    DST="${EXTRA_DST[i]}"
    if [ -e "$SRC" ]; then
        echo "Copiando $SRC --> $DST (requiere permisos de superusuario)"
        if [ "$(ls -A "$SRC")" ]; then
            sudo cp -ru "$SRC/"* "$DST/"
            echo "Copiado: $SRC --> $DST"
        else
            echo "La carpeta $SRC está vacía, omitiendo copia..."
        fi
    else
        echo "No existe $SRC, creando carpeta en el repositorio..."
        mkdir -p "$SRC"
        echo "Carpeta creada: $SRC"
    fi
done

echo "Instalación y copia de configuraciones completada."
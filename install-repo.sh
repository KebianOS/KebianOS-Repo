#!/bin/bash

set -e

REPO_NAME="kebianos"
REPO_URL="https://KebianOS.github.io/KebianOS-Repo"
KEY_URL="$REPO_URL/kebianos-repo.asc"
KEYRING="/usr/share/keyrings/${REPO_NAME}-repo.gpg"
SOURCES="/etc/apt/sources.list.d/${REPO_NAME}.list"

echo "=== Instalador del repositorio KebianOS ==="

# Comprobar root
if [ "$EUID" -ne 0 ]; then
    echo "Error: ejecuta este script como root."
    echo "Ejemplo:"
    echo "  sudo ./install-repo.sh"
    exit 1
fi

echo "[1/3] Descargando clave pública..."

curl -fsSL "$KEY_URL" \
    | gpg --dearmor \
    > "$KEYRING"

chmod 644 "$KEYRING"

echo "[2/3] Configurando repositorio APT..."

cat > "$SOURCES" <<EOF
deb [signed-by=$KEYRING] $REPO_URL stable main
EOF

echo "[3/3] Actualizando índices APT..."

apt update

echo
echo "========================================"
echo "Repositorio KebianOS instalado."
echo "========================================"
echo
echo "Puedes buscar paquetes con:"
echo
echo "    apt search hello-world"
echo
echo "Y puedes instalarlos con:"
echo
echo "    apt install hello-world"
echo

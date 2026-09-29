#!/bin/bash

set -e

REPO_NAME="kebianos"
REPO_URL="https://KebianOS.github.io/KebianOS-Repo"
KEY_URL="$REPO_URL/kebianos-repo.asc"
EXPECTED_KEY_FINGERPRINT="F555BE827AEB520DA15764B602363A0BDE49A0B3"
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

TEMP_KEY="$(mktemp)"
trap 'rm -f "$TEMP_KEY"' EXIT
curl -fsSL "$KEY_URL" -o "$TEMP_KEY"

ACTUAL_KEY_FINGERPRINT="$(gpg --show-keys --with-colons "$TEMP_KEY" \
    | awk -F: '$1 == "fpr" { print $10; exit }')"
if [ "$ACTUAL_KEY_FINGERPRINT" != "$EXPECTED_KEY_FINGERPRINT" ]; then
    echo "Error: el fingerprint de la clave descargada no coincide." >&2
    exit 1
fi

gpg --dearmor --output "$KEYRING" "$TEMP_KEY"

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

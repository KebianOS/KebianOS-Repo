#!/bin/bash

set -e

REPO_DIR="apt-repo"
DIST="stable"
COMPONENT="main"
ARCH="all"
GPG_KEY="C83E67C35AB8BB5049F29221833A6DE3E042D9D0"
GPG_KEY_FILE="kebianos-repo.asc"


echo "=== Construyendo repositorio KebianOS ==="
echo "[0/5] Exportando clave pública..."

gpg --armor \
    --export "$GPG_KEY" \
    > "$GPG_KEY_FILE"

echo "[1/5] Generando Packages y Packages.gz..."

dpkg-scanpackages \
    "$REPO_DIR/pool" \
    /dev/null \
    > "$REPO_DIR/dists/$DIST/$COMPONENT/binary-$ARCH/Packages"
gzip -9 -c \
    "$REPO_DIR/dists/$DIST/$COMPONENT/binary-$ARCH/Packages" \
    > "$REPO_DIR/dists/$DIST/$COMPONENT/binary-$ARCH/Packages.gz"

echo "[2/5] Generando Release..."

apt-ftparchive \
    -o APT::FTPArchive::Release::Origin="KebianOS" \
    -o APT::FTPArchive::Release::Label="KebianOS" \
    -o APT::FTPArchive::Release::Suite="$DIST" \
    -o APT::FTPArchive::Release::Codename="$DIST" \
    -o APT::FTPArchive::Release::Architectures="$ARCH" \
    -o APT::FTPArchive::Release::Components="$COMPONENT" \
    -o APT::FTPArchive::Release::Description="Repositorio APT de KebianOS" \
    release "$REPO_DIR/dists/$DIST" \
    > "$REPO_DIR/dists/$DIST/Release"



echo "[3/5] Firmando Release..."

gpg --batch \
    --yes \
    --local-user "$GPG_KEY" \
    --clearsign \
    --output "$REPO_DIR/dists/$DIST/InRelease" \
    "$REPO_DIR/dists/$DIST/Release"


echo "[4/5] Generando Release.gpg..."

gpg --batch \
    --yes \
    --local-user "$GPG_KEY" \
    --detach-sign \
    --output "$REPO_DIR/dists/$DIST/Release.gpg" \
    "$REPO_DIR/dists/$DIST/Release"



echo "[5/5] Subiendo al repo..."
git add .
git commit -m "KebianOS"
git push

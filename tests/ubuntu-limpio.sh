#!/usr/bin/env bash
# Prueba completa en un Ubuntu limpio: instala, verifica, repite, abre las apps y desinstala.
# Uso: tests/ubuntu-limpio.sh [24.04|26.04] [amd64|arm64]
set -euo pipefail

UBUNTU="${1:-24.04}"
ARQ="${2:-amd64}"
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
IMAGEN="campuslands-ai-installer-prueba:$UBUNTU-$ARQ"
SALIDA="$RAIZ/tests/resultados/$UBUNTU-$ARQ"
mkdir -p "$SALIDA"
chmod 777 "$SALIDA"

docker build --platform "linux/$ARQ" --build-arg "UBUNTU=$UBUNTU" -t "$IMAGEN" -f "$RAIZ/tests/Dockerfile.ubuntu" "$RAIZ/tests"

docker run --rm --platform "linux/$ARQ" --shm-size=1g \
  -v "$RAIZ:/repo:ro" -v "$SALIDA:/salida" "$IMAGEN" bash -c '
    set -euo pipefail
    cp -r /repo ~/instalador
    cd ~/instalador
    echo "=== 1. Instalación"
    ./install.sh
    echo "=== 2. Verificación"
    ./install.sh --verificar
    touch ~/Documentos/"Campuslands Vault"/mi-nota.md 2>/dev/null || touch ~/Documents/"Campuslands Vault"/mi-nota.md
    echo "=== 3. Segunda ejecución"
    ./install.sh
    ./install.sh --verificar
    echo "=== 4. Apertura de apps"
    bash tests/humo-gui.sh /salida
    echo "=== 5. Desinstalación"
    ./install.sh --desinstalar
    ! command -v chatgpt
    [[ ! -e /opt/antigravity ]]
    [[ ! -e /opt/Obsidian/obsidian ]]
    ls ~/Documentos/"Campuslands Vault"/mi-nota.md 2>/dev/null || ls ~/Documents/"Campuslands Vault"/mi-nota.md
    echo "=== TODO BIEN"
  ' 2>&1 | tee "$SALIDA/registro.txt"

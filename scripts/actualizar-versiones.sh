#!/usr/bin/env bash
# Para mantenedores: busca las versiones publicadas de Antigravity y Obsidian,
# calcula sus huellas SHA-256 y reescribe config/versiones.conf.
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$RAIZ/config/versiones.conf"
TRABAJO="$(mktemp -d)"
trap 'rm -rf "$TRABAJO"' EXIT
UA='Mozilla/5.0 (X11; Linux x86_64)'

sha_remoto() {
  curl -fsSL -A "$UA" "$1" | sha256sum | cut -d' ' -f1
}

reemplazar() {
  sed -i.bak "s|^$1=.*|$1=\"$2\"|" "$CONF"
  rm -f "$CONF.bak"
}

# La página de descargas trae los enlaces de la versión vigente en su HTML.
curl -fsSL -A "$UA" https://antigravity.google/download -o "$TRABAJO/pagina.html"
ruta_ag="$(grep -oE 'antigravity-hub/[0-9.]+-[0-9]+/linux-x64' "$TRABAJO/pagina.html" | head -1 || true)"
[[ -n "$ruta_ag" ]] || {
  echo "No encontré la versión de Antigravity en la página de descargas." >&2
  exit 1
}
ver_ag="${ruta_ag#antigravity-hub/}"
ver_ag="${ver_ag%/*}"
build_ag="${ver_ag#*-}"
ver_ag="${ver_ag%-*}"
base_ag="https://storage.googleapis.com/antigravity-public/antigravity-hub/$ver_ag-$build_ag"
reemplazar ANTIGRAVITY_VERSION "$ver_ag"
reemplazar ANTIGRAVITY_BUILD "$build_ag"
reemplazar ANTIGRAVITY_SHA256_AMD64 "$(sha_remoto "$base_ag/linux-x64/Antigravity.tar.gz")"
reemplazar ANTIGRAVITY_SHA256_ARM64 "$(sha_remoto "$base_ag/linux-arm/Antigravity.tar.gz")"

ver_ob="$(curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"].lstrip("v"))')"
base_ob="https://github.com/obsidianmd/obsidian-releases/releases/download/v$ver_ob"
reemplazar OBSIDIAN_VERSION "$ver_ob"
reemplazar OBSIDIAN_SHA256_AMD64 "$(sha_remoto "$base_ob/obsidian_${ver_ob}_amd64.deb")"
reemplazar OBSIDIAN_SHA256_ARM64 "$(sha_remoto "$base_ob/Obsidian-${ver_ob}-arm64.AppImage")"

echo "Antigravity $ver_ag y Obsidian $ver_ob. Prueba con tests/ubuntu-limpio.sh antes de publicar."

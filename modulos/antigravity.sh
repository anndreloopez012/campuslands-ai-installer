#!/usr/bin/env bash
# Google Antigravity: App de escritorio (tar.gz oficial) y CLI agy (instalador oficial).
# Google no publica .deb, así que aquí se hace la integración con el sistema.

ANTIGRAVITY_DIR="/opt/antigravity"
ANTIGRAVITY_DESKTOP="/usr/share/applications/antigravity.desktop"
ANTIGRAVITY_ICONO="/usr/share/icons/hicolor/512x512/apps/antigravity.png"
ANTIGRAVITY_URL_CLI="https://antigravity.google/cli/install.sh"
ANTIGRAVITY_DEPENDENCIAS=(libasound2t64 libgbm1 libgtk-3-0t64 libnotify4 libnss3 libsecret-1-0 libxss1 libxtst6 xdg-utils)

antigravity_nombre() { echo "Google Antigravity App + CLI"; }

antigravity_instalado() { [[ -x "$ANTIGRAVITY_DIR/antigravity" ]]; }

antigravity_version() { cat "$ANTIGRAVITY_DIR/.campuslands-version" 2>/dev/null; }

_antigravity_url() {
  local carpeta=linux-x64
  [[ "$CL_ARQ" == "arm64" ]] && carpeta=linux-arm
  echo "https://storage.googleapis.com/antigravity-public/antigravity-hub/${ANTIGRAVITY_VERSION}-${ANTIGRAVITY_BUILD}/${carpeta}/Antigravity.tar.gz"
}

_antigravity_sha() {
  if [[ "$CL_ARQ" == "arm64" ]]; then echo "$ANTIGRAVITY_SHA256_ARM64"; else echo "$ANTIGRAVITY_SHA256_AMD64"; fi
}

_antigravity_lanzador() {
  local temporal
  temporal="$(mktemp)"
  # MimeType registra antigravity:// : sin él, el regreso del login no llega a la app.
  cat >"$temporal" <<EOF
[Desktop Entry]
Name=Antigravity
Comment=Plataforma de desarrollo con agentes de Google
GenericName=Agentes de programación
Exec=$ANTIGRAVITY_DIR/antigravity %U
Icon=antigravity
Type=Application
StartupNotify=true
StartupWMClass=Antigravity
Categories=Development;
MimeType=x-scheme-handler/antigravity;
EOF
  como_root install -m 0644 "$temporal" "$ANTIGRAVITY_DESKTOP"
  rm -f "$temporal"
}

_antigravity_app() {
  if [[ "$(antigravity_version)" == "$ANTIGRAVITY_VERSION" ]]; then
    ok "Antigravity App $ANTIGRAVITY_VERSION ya estaba instalada"
    return 0
  fi
  local paquete="$CL_CACHE/Antigravity-${ANTIGRAVITY_VERSION}-${CL_ARQ}.tar.gz" nuevo="$ANTIGRAVITY_DIR.nuevo"
  info "Descargando Antigravity (unos 180 MB)"
  descargar "$(_antigravity_url)" "$paquete" "$(_antigravity_sha)"
  apt_root install -y "${ANTIGRAVITY_DEPENDENCIAS[@]}"

  como_root rm -rf "$nuevo"
  como_root mkdir -p "$nuevo"
  como_root tar -xzf "$paquete" -C "$nuevo" --strip-components=1 --no-same-owner
  como_root chown -R root:root "$nuevo"
  como_root chmod 4755 "$nuevo/chrome-sandbox"
  ejecutar bash -c "echo '$ANTIGRAVITY_VERSION' | sudo tee '$nuevo/.campuslands-version' >/dev/null"
  # La versión anterior se reemplaza solo cuando la nueva ya está completa.
  como_root rm -rf "$ANTIGRAVITY_DIR"
  como_root mv "$nuevo" "$ANTIGRAVITY_DIR"
  como_root ln -sf "$ANTIGRAVITY_DIR/antigravity" /usr/local/bin/antigravity

  if [[ "$CL_SIMULAR" != "1" ]]; then
    local icono
    icono="$(mktemp)"
    python3 "$CL_RAIZ/lib/extraer_asar.py" "$ANTIGRAVITY_DIR/resources/app.asar" icon.png "$icono"
    como_root install -D -m 0644 "$icono" "$ANTIGRAVITY_ICONO"
    rm -f "$icono"
  fi
  _antigravity_lanzador
  instalar_perfil_apparmor antigravity "$ANTIGRAVITY_DIR/antigravity"
  refrescar_escritorio
  ejecutar rm -f "$paquete"
}

antigravity_instalar() {
  _antigravity_app
  if [[ ! -x "$HOME/.local/bin/agy" ]]; then
    ejecutar_script_oficial "$ANTIGRAVITY_URL_CLI" bash
  fi
  if tiene_comando xdg-mime; then
    ejecutar xdg-mime default antigravity.desktop x-scheme-handler/antigravity
  fi
}

antigravity_verificar() {
  antigravity_instalado && [[ -f "$ANTIGRAVITY_DESKTOP" && -f "$ANTIGRAVITY_ICONO" && -x "$HOME/.local/bin/agy" ]]
}

antigravity_desinstalar() {
  como_root rm -rf "$ANTIGRAVITY_DIR"
  como_root rm -f "$ANTIGRAVITY_DESKTOP" "$ANTIGRAVITY_ICONO" /usr/local/bin/antigravity /etc/apparmor.d/antigravity
  ejecutar rm -f "$HOME/.local/bin/agy"
  refrescar_escritorio
}

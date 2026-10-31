#!/usr/bin/env bash
# Obsidian: .deb oficial en amd64. En arm64 solo existe el AppImage oficial,
# que se desempaca en /opt para no depender de FUSE.

OBSIDIAN_BASE="https://github.com/obsidianmd/obsidian-releases/releases/download"
OBSIDIAN_DIR="/opt/Obsidian"
OBSIDIAN_DESKTOP="/usr/share/applications/md.obsidian.Obsidian.desktop"
OBSIDIAN_ICONO="/usr/share/icons/hicolor/512x512/apps/md.obsidian.Obsidian.png"

obsidian_nombre() { echo "Obsidian"; }

obsidian_instalado() { [[ -x "$OBSIDIAN_DIR/obsidian" ]]; }

obsidian_version() {
  if [[ -f "$OBSIDIAN_DIR/.campuslands-version" ]]; then
    cat "$OBSIDIAN_DIR/.campuslands-version"
  else
    dpkg-query -W -f='${Version}' obsidian 2>/dev/null
  fi
}

_obsidian_deb() {
  local paquete="$CL_CACHE/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
  info "Descargando Obsidian (unos 100 MB)"
  descargar "$OBSIDIAN_BASE/v$OBSIDIAN_VERSION/obsidian_${OBSIDIAN_VERSION}_amd64.deb" "$paquete" "$OBSIDIAN_SHA256_AMD64"
  apt_root install -y "$paquete"
  ejecutar rm -f "$paquete"
}

_obsidian_appimage() {
  local paquete="$CL_CACHE/Obsidian-${OBSIDIAN_VERSION}-arm64.AppImage" trabajo
  info "Descargando Obsidian (unos 150 MB)"
  descargar "$OBSIDIAN_BASE/v$OBSIDIAN_VERSION/Obsidian-${OBSIDIAN_VERSION}-arm64.AppImage" "$paquete" "$OBSIDIAN_SHA256_ARM64"
  # zlib1g-dev aporta libz.so, que el AppImage necesita para desempacarse.
  apt_root install -y libgtk-3-0t64 libnotify4 libnss3 libsecret-1-0 libxss1 libxtst6 xdg-utils zlib1g-dev
  [[ "$CL_SIMULAR" == "1" ]] && return 0

  chmod +x "$paquete"
  trabajo="$(mktemp -d)"
  (cd "$trabajo" && "$paquete" --appimage-extract >/dev/null)
  como_root rm -rf "$OBSIDIAN_DIR"
  como_root mv "$trabajo/squashfs-root" "$OBSIDIAN_DIR"
  como_root chown -R root:root "$OBSIDIAN_DIR"
  como_root chmod -R u+rwX,go+rX "$OBSIDIAN_DIR"
  como_root chmod 4755 "$OBSIDIAN_DIR/chrome-sandbox"
  echo "$OBSIDIAN_VERSION" | sudo tee "$OBSIDIAN_DIR/.campuslands-version" >/dev/null
  como_root ln -sf "$OBSIDIAN_DIR/obsidian" /usr/local/bin/obsidian
  como_root install -D -m 0644 "$OBSIDIAN_DIR/usr/share/icons/hicolor/512x512/apps/obsidian.png" "$OBSIDIAN_ICONO"

  local temporal
  temporal="$(mktemp)"
  cat >"$temporal" <<EOF
[Desktop Entry]
Name=Obsidian
Comment=Base de conocimiento en notas Markdown
Exec=$OBSIDIAN_DIR/obsidian %U
Icon=md.obsidian.Obsidian
Type=Application
StartupNotify=true
StartupWMClass=obsidian
Categories=Office;
MimeType=x-scheme-handler/obsidian;
EOF
  como_root install -m 0644 "$temporal" "$OBSIDIAN_DESKTOP"
  rm -f "$temporal" "$paquete"
  rm -rf "$trabajo"
  instalar_perfil_apparmor obsidian "$OBSIDIAN_DIR/obsidian"
  refrescar_escritorio
}

obsidian_instalar() {
  if [[ "$(obsidian_version)" == "$OBSIDIAN_VERSION" ]]; then
    ok "Obsidian $OBSIDIAN_VERSION ya estaba instalado"
    return 0
  fi
  if [[ "$CL_ARQ" == "arm64" ]]; then _obsidian_appimage; else _obsidian_deb; fi
}

obsidian_verificar() { obsidian_instalado && [[ -f "$OBSIDIAN_DESKTOP" ]]; }

obsidian_desinstalar() {
  if dpkg-query -W -f='${Status}' obsidian 2>/dev/null | grep -q 'ok installed'; then
    apt_root purge -y obsidian
  else
    como_root rm -rf "$OBSIDIAN_DIR"
    como_root rm -f "$OBSIDIAN_DESKTOP" "$OBSIDIAN_ICONO" /usr/local/bin/obsidian /etc/apparmor.d/obsidian
    refrescar_escritorio
  fi
}

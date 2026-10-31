#!/usr/bin/env bash
# Utilidades compartidas: mensajes, ejecución con permisos y descargas verificadas.

CL_SIMULAR="${CL_SIMULAR:-0}"
CL_CACHE="${CL_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/campuslands-ai-installer}"
# El lector de color se apaga si la salida no es una terminal.
if [[ -t 1 ]]; then
  C_AZUL=$'\033[1;34m' C_VERDE=$'\033[1;32m' C_AMARILLO=$'\033[1;33m' C_ROJO=$'\033[1;31m' C_FIN=$'\033[0m'
else
  C_AZUL='' C_VERDE='' C_AMARILLO='' C_ROJO='' C_FIN=''
fi

paso() { printf '\n%s==> %s%s\n' "$C_AZUL" "$1" "$C_FIN"; }
info() { printf '    %s\n' "$1"; }
ok() { printf '%s  ✓ %s%s\n' "$C_VERDE" "$1" "$C_FIN"; }
aviso() { printf '%s  ! %s%s\n' "$C_AMARILLO" "$1" "$C_FIN" >&2; }
error() { printf '%s  ✗ %s%s\n' "$C_ROJO" "$1" "$C_FIN" >&2; }
morir() {
  error "$1"
  exit 1
}

tiene_comando() { command -v "$1" >/dev/null 2>&1; }

# Ejecuta un comando, o solo lo muestra en modo simulación.
ejecutar() {
  if [[ "$CL_SIMULAR" == "1" ]]; then
    printf '    [simulación] %s\n' "$*"
    return 0
  fi
  "$@"
}

como_root() {
  ejecutar sudo "$@"
}

# apt espera el candado: Ubuntu recién instalado suele estar actualizándose solo.
apt_root() {
  como_root env DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=600 "$@"
}

sha256_de() {
  sha256sum "$1" | cut -d' ' -f1
}

# descargar URL DESTINO [SHA256]: reanuda cortes y comprueba la huella si se indica.
descargar() {
  local url="$1" destino="$2" esperado="${3:-}"
  if [[ "$CL_SIMULAR" == "1" ]]; then
    printf '    [simulación] descargar %s\n' "$url"
    return 0
  fi
  mkdir -p "$(dirname "$destino")"
  if [[ -n "$esperado" && -f "$destino" && "$(sha256_de "$destino")" == "$esperado" ]]; then
    info "Ya estaba descargado: $(basename "$destino")"
    return 0
  fi
  rm -f "$destino"
  curl --proto '=https' --tlsv1.2 -fL --retry 5 --retry-delay 3 --retry-all-errors \
    -C - --progress-bar -o "$destino.parte" "$url" || morir "No se pudo descargar $url"
  mv "$destino.parte" "$destino"
  if [[ -n "$esperado" && "$(sha256_de "$destino")" != "$esperado" ]]; then
    rm -f "$destino"
    morir "La huella SHA-256 no coincide: $url. Se borró el archivo; avisa al instructor."
  fi
}

# Baja un instalador oficial a un archivo temporal para no ejecutar una tubería a ciegas.
ejecutar_script_oficial() {
  local url="$1" interprete="$2" temporal
  shift 2
  if [[ "$CL_SIMULAR" == "1" ]]; then
    printf '    [simulación] ejecutar instalador oficial %s\n' "$url"
    return 0
  fi
  temporal="$(mktemp)"
  descargar "$url" "$temporal"
  "$interprete" "$temporal" "$@" </dev/null
  rm -f "$temporal"
}

# Instala un perfil AppArmor para que el sandbox de Electron funcione en Ubuntu 24.04+.
instalar_perfil_apparmor() {
  local nombre="$1" binario="$2" temporal
  [[ -f /etc/apparmor.d/abi/4.0 ]] || return 0
  temporal="$(mktemp)"
  cat >"$temporal" <<EOF
abi <abi/4.0>,
include <tunables/global>

profile $nombre "$binario" flags=(unconfined) {
  userns,
  include if exists <local/$nombre>
}
EOF
  como_root install -m 0644 "$temporal" "/etc/apparmor.d/$nombre"
  rm -f "$temporal"
  if tiene_comando aa-enabled && aa-enabled --quiet 2>/dev/null; then
    como_root apparmor_parser -r -W -T "/etc/apparmor.d/$nombre"
  fi
}

refrescar_escritorio() {
  como_root update-desktop-database /usr/share/applications 2>/dev/null || true
  if tiene_comando gtk-update-icon-cache; then
    como_root gtk-update-icon-cache -q -t /usr/share/icons/hicolor 2>/dev/null || true
  fi
}

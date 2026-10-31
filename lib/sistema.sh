#!/usr/bin/env bash
# Detección del equipo. Las rutas se pueden cambiar para probar sin un Ubuntu real.

CL_OS_RELEASE="${CL_OS_RELEASE:-/etc/os-release}"
CL_ESPACIO_MINIMO_GB=8
CL_UBUNTU_SOPORTADAS="24.04 26.04"

# Lee una variable de os-release en un subproceso para no ensuciar el entorno.
leer_os_release() {
  (
    # shellcheck disable=SC1090
    . "$CL_OS_RELEASE"
    printf '%s' "${!1:-}"
  )
}

detectar_arquitectura() {
  case "$(uname -m)" in
    x86_64 | amd64) echo amd64 ;;
    aarch64 | arm64) echo arm64 ;;
    *) return 1 ;;
  esac
}

ubuntu_soportada() {
  local version="$1" soportada
  for soportada in $CL_UBUNTU_SOPORTADAS; do
    [[ "$version" == "$soportada" ]] && return 0
  done
  return 1
}

es_escritorio() {
  dpkg-query -W -f='${Status}' gnome-shell 2>/dev/null | grep -q 'ok installed'
}

espacio_libre_gb() {
  df -BG --output=avail "${1:-/}" | tail -1 | tr -dc '0-9'
}

# Comprueba el equipo. Con --forzar, lo no soportado solo avisa.
comprobar_sistema() {
  local forzar="${1:-0}" id version
  id="$(leer_os_release ID)"
  version="$(leer_os_release VERSION_ID)"

  if [[ "$id" != "ubuntu" ]]; then
    [[ "$forzar" == "1" ]] || morir "Este instalador es para Ubuntu y detecté: ${id:-desconocido}."
    aviso "Sistema no soportado (${id:-desconocido}); sigo por --forzar."
  elif ! ubuntu_soportada "$version"; then
    [[ "$forzar" == "1" ]] || morir "Ubuntu $version no está soportado. Usa: $CL_UBUNTU_SOPORTADAS."
    aviso "Ubuntu $version no está soportado; sigo por --forzar."
  fi

  CL_ARQ="$(detectar_arquitectura)" || morir "Arquitectura no soportada: $(uname -m)."
  export CL_ARQ

  if ! es_escritorio; then
    [[ "$forzar" == "1" ]] || morir "Hace falta Ubuntu Desktop: no encontré el escritorio GNOME."
    aviso "No encontré el escritorio GNOME; sigo por --forzar."
  fi

  local libre
  libre="$(espacio_libre_gb /)"
  if ((libre < CL_ESPACIO_MINIMO_GB)); then
    morir "Hay ${libre} GB libres y hacen falta ${CL_ESPACIO_MINIMO_GB} GB."
  fi
  ok "Ubuntu ${version:-?} ($CL_ARQ) con ${libre} GB libres"
}

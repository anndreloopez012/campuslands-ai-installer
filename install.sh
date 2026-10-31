#!/usr/bin/env bash
# Campuslands AI Installer: prepara Ubuntu Desktop con ChatGPT, Codex, Antigravity y Obsidian.
# Todo va dentro de funciones para que bash lea el archivo completo antes de ejecutar,
# requisito para que funcione también con: wget -qO- URL | bash
set -Eeuo pipefail

CL_VERSION="1.0.0"
CL_REPO="anndreloopez012/campuslands-ai-installer"
CL_MODULOS="chatgpt codex antigravity obsidian vault menu"

mostrar_ayuda() {
  cat <<EOF
Campuslands AI Installer $CL_VERSION

Uso: ./install.sh [opciones]

  (sin opciones)      Instala todo; repetirlo actualiza sin perder nada
  --verificar         Revisa qué está instalado, sin cambiar nada
  --solo a,b          Instala solo esos módulos
  --omitir a,b        Instala todo menos esos módulos
  --vault RUTA        Crea el vault en esa carpeta
  --simular           Muestra lo que haría, sin cambiar nada
  --desinstalar       Quita las apps; el vault se conserva
  --forzar            Sigue en un sistema no soportado
  -h, --help          Muestra esta ayuda
  --version           Muestra la versión

Módulos: ${CL_MODULOS// /, }
EOF
}

# Sin lib/ al lado significa que llegó por una tubería: baja el proyecto y vuelve a entrar.
arrancar_desde_github() {
  local temporal url="https://github.com/$CL_REPO/archive/refs/heads/main.tar.gz"
  temporal="$(mktemp -d)"
  echo "Descargando Campuslands AI Installer..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" | tar -xz -C "$temporal" --strip-components=1
  else
    wget -qO- "$url" | tar -xz -C "$temporal" --strip-components=1
  fi
  if (: </dev/tty) 2>/dev/null; then
    exec bash "$temporal/install.sh" "$@" </dev/tty
  fi
  exec bash "$temporal/install.sh" "$@" </dev/null
}

cargar_proyecto() {
  # shellcheck source=lib/comun.sh
  . "$CL_RAIZ/lib/comun.sh"
  # shellcheck source=lib/sistema.sh
  . "$CL_RAIZ/lib/sistema.sh"
  # shellcheck source=config/versiones.conf
  . "$CL_RAIZ/config/versiones.conf"
  local modulo
  for modulo in $CL_MODULOS; do
    # shellcheck disable=SC1090
    . "$CL_RAIZ/modulos/$modulo.sh"
  done
}

leer_lista() {
  local crudo="$1" modulo
  for modulo in ${crudo//,/ }; do
    [[ " $CL_MODULOS " == *" $modulo "* ]] || morir "Módulo desconocido: $modulo. Usa: $CL_MODULOS"
    printf '%s ' "$modulo"
  done
}

quitar_de_lista() {
  local modulo
  for modulo in $CL_MODULOS; do
    [[ " $1 " == *" $modulo "* ]] || printf '%s ' "$modulo"
  done
}

leer_argumentos() {
  CL_ACCION=instalar CL_FORZAR=0 CL_SELECCION="$CL_MODULOS"
  while (($#)); do
    case "$1" in
      --verificar) CL_ACCION=verificar ;;
      --desinstalar) CL_ACCION=desinstalar ;;
      --simular) CL_SIMULAR=1 ;;
      --forzar) CL_FORZAR=1 ;;
      --solo)
        [[ -n "${2:-}" ]] || morir "--solo necesita una lista de módulos."
        CL_SELECCION="$(leer_lista "$2")"
        shift
        ;;
      --omitir)
        [[ -n "${2:-}" ]] || morir "--omitir necesita una lista de módulos."
        leer_lista "$2" >/dev/null
        CL_SELECCION="$(quitar_de_lista "$(leer_lista "$2")")"
        shift
        ;;
      --vault)
        [[ -n "${2:-}" ]] || morir "--vault necesita una ruta."
        export CL_VAULT="$2"
        shift
        ;;
      -h | --help)
        mostrar_ayuda
        exit 0
        ;;
      --version)
        echo "$CL_VERSION"
        exit 0
        ;;
      *) morir "Opción desconocida: $1 (usa --help)" ;;
    esac
    shift
  done
}

pedir_permisos() {
  [[ "$CL_SIMULAR" == "1" ]] && return 0
  info "Se pedirá tu contraseña para instalar en el sistema."
  sudo -v || morir "Hacen falta permisos de administrador (sudo)."
  # Las descargas largas no deben volver a pedir la contraseña a mitad de camino.
  (while kill -0 $$ 2>/dev/null; do
    sudo -n true
    sleep 50
  done) >/dev/null 2>&1 &
}

preparar_base() {
  paso "Preparando el sistema"
  apt_root update
  apt_root install -y ca-certificates curl gnupg python3 tar xdg-user-dirs xdg-utils
}

# set -e no actúa dentro de un if, ni siquiera en un subproceso: esta función nunca debe
# llamarse como condición. Deja el resultado en CL_ESTADO.
correr_modulo() {
  local funcion="$1"
  set +e
  (
    set -e
    "$funcion"
  )
  CL_ESTADO=$?
  set -e
}

modulo_completo() {
  [[ "$CL_SIMULAR" == "1" ]] || "$1_verificar"
}

accion_instalar() {
  local modulo fallos=()
  comprobar_sistema "$CL_FORZAR"
  pedir_permisos
  preparar_base
  export PATH="$HOME/.local/bin:$PATH"
  for modulo in $CL_SELECCION; do
    paso "$("${modulo}_nombre")"
    correr_modulo "${modulo}_instalar"
    if ((CL_ESTADO == 0)) && modulo_completo "$modulo"; then
      ok "$("${modulo}_nombre") listo"
    else
      error "Falló: $("${modulo}_nombre")"
      fallos+=("$modulo")
    fi
  done
  if ((${#fallos[@]})); then
    error "Quedó pendiente: ${fallos[*]}. Vuelve a ejecutar el instalador; retoma donde quedó."
    return 1
  fi
  [[ "$CL_SIMULAR" == "1" ]] && return 0
  cat <<EOF

${C_VERDE}Listo.${C_FIN} Cierra sesión y vuelve a entrar para que todo quede en el menú.

Luego, entra con tu propia cuenta en cada programa:
  1. ChatGPT: abre la app e inicia sesión. Codex está dentro de esa app.
  2. Antigravity: abre la app e inicia sesión con Google.
  3. Terminal: ejecuta 'codex' y 'agy' para conectar las versiones de consola.
  4. Obsidian: abre la app; tu vault ya está cargado.
EOF
}

accion_verificar() {
  local modulo nombre faltantes=0
  paso "Estado del equipo"
  for modulo in $CL_SELECCION; do
    nombre="$("${modulo}_nombre")"
    if "${modulo}_verificar"; then
      ok "$nombre ($("${modulo}_version" || true))"
    else
      error "$nombre: falta o está incompleto"
      faltantes=$((faltantes + 1))
    fi
  done
  ((faltantes == 0))
}

accion_desinstalar() {
  local modulo
  pedir_permisos
  for modulo in $(tr ' ' '\n' <<<"$CL_SELECCION" | tac); do
    paso "Quitando $("${modulo}_nombre")"
    correr_modulo "${modulo}_desinstalar"
    ((CL_ESTADO == 0)) || error "No se pudo quitar: $modulo"
  done
}

main() {
  local origen="${BASH_SOURCE[0]:-}"
  if [[ -z "$origen" || ! -f "$(dirname "$origen")/lib/comun.sh" ]]; then
    arrancar_desde_github "$@"
  fi
  CL_RAIZ="$(cd "$(dirname "$origen")" && pwd)"
  export CL_RAIZ
  cargar_proyecto

  [[ "$(id -u)" != "0" ]] || morir "Ejecútalo con tu usuario normal, sin sudo: el vault y las CLI son tuyos."
  leer_argumentos "$@"

  local registro="${XDG_STATE_HOME:-$HOME/.local/state}/campuslands-ai-installer"
  mkdir -p "$registro"
  if [[ "$CL_ACCION" != "verificar" ]]; then
    exec > >(tee -a "$registro/instalacion.log") 2>&1
  fi
  CL_ARQ="$(detectar_arquitectura || true)"
  export CL_ARQ
  "accion_$CL_ACCION"
}

main "$@"

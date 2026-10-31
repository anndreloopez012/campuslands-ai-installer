#!/usr/bin/env bash
# Menú de aplicaciones: carpeta "Campuslands IA" en GNOME.

MENU_ID="Campuslands-IA"
MENU_RUTA="/org/gnome/desktop/app-folders/folders/$MENU_ID/"
MENU_ESQUEMA="org.gnome.desktop.app-folders"
MENU_APPS=(chatgpt.desktop antigravity.desktop md.obsidian.Obsidian.desktop)

menu_nombre() { echo "Menú de aplicaciones"; }

_menu_gsettings() {
  if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    gsettings "$@"
  else
    dbus-run-session -- gsettings "$@"
  fi
}

_menu_disponible() {
  # Sin grep -q: al salir antes de tiempo mata a gsettings y pipefail lo toma como fallo.
  tiene_comando gsettings && gsettings list-schemas 2>/dev/null | grep -x "$MENU_ESQUEMA" >/dev/null
}

_menu_lista_json() {
  python3 -c 'import json,sys; print(str(sys.argv[1:]))' "$@"
}

# Suma el id a folder-children sin perder las carpetas que ya tenga la persona.
_menu_hijos() {
  python3 - "$1" "$MENU_ID" "${2:-agregar}" <<'PY'
import ast
import sys

actual = sys.argv[1]
actual = actual[actual.index("["):] if "[" in actual else "[]"
hijos = ast.literal_eval(actual)
if sys.argv[3] == "agregar" and sys.argv[2] not in hijos:
    hijos.append(sys.argv[2])
if sys.argv[3] == "quitar" and sys.argv[2] in hijos:
    hijos.remove(sys.argv[2])
print(hijos)
PY
}

menu_instalado() {
  _menu_disponible && _menu_gsettings get "$MENU_ESQUEMA" folder-children | grep "$MENU_ID" >/dev/null
}

menu_version() { echo "carpeta Campuslands IA"; }

menu_instalar() {
  if ! _menu_disponible; then
    aviso "GNOME no está disponible aquí; las apps quedan en el menú normal."
    return 0
  fi
  local apps=() app
  for app in "${MENU_APPS[@]}"; do
    [[ -f "/usr/share/applications/$app" ]] && apps+=("$app")
  done
  ejecutar _menu_gsettings set "$MENU_ESQUEMA.folder:$MENU_RUTA" name "Campuslands IA"
  ejecutar _menu_gsettings set "$MENU_ESQUEMA.folder:$MENU_RUTA" apps "$(_menu_lista_json "${apps[@]}")"
  ejecutar _menu_gsettings set "$MENU_ESQUEMA" folder-children \
    "$(_menu_hijos "$(_menu_gsettings get "$MENU_ESQUEMA" folder-children)")"
}

menu_verificar() {
  _menu_disponible || return 0
  menu_instalado
}

menu_desinstalar() {
  _menu_disponible || return 0
  ejecutar _menu_gsettings set "$MENU_ESQUEMA" folder-children \
    "$(_menu_hijos "$(_menu_gsettings get "$MENU_ESQUEMA" folder-children)" quitar)"
  ejecutar _menu_gsettings reset-recursively "$MENU_ESQUEMA.folder:$MENU_RUTA"
}

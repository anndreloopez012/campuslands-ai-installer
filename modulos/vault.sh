#!/usr/bin/env bash
# Vault de Obsidian: estructura y plantillas. Nunca sobrescribe notas existentes.

CL_NOMBRE_VAULT="Campuslands Vault"

vault_nombre() { echo "Vault de Obsidian"; }

vault_ruta() {
  if [[ -n "${CL_VAULT:-}" ]]; then
    echo "$CL_VAULT"
    return 0
  fi
  local documentos
  documentos="$(xdg-user-dir DOCUMENTS 2>/dev/null || true)"
  if [[ -z "$documentos" || "$documentos" == "$HOME" ]]; then
    documentos="$HOME/Documentos"
  fi
  echo "$documentos/$CL_NOMBRE_VAULT"
}

vault_instalado() { [[ -d "$(vault_ruta)/.obsidian" ]]; }

vault_version() { vault_ruta; }

# Da de alta el vault para que Obsidian lo abra sin preguntar, conservando los que ya haya.
_vault_registrar() {
  local ruta="$1" config="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/obsidian.json"
  python3 - "$ruta" "$config" <<'PY'
import hashlib
import json
import os
import sys
import time

ruta, config = sys.argv[1], sys.argv[2]
datos = {}
if os.path.exists(config):
    with open(config, encoding="utf-8") as archivo:
        datos = json.load(archivo)
vaults = datos.setdefault("vaults", {})
if not any(v.get("path") == ruta for v in vaults.values()):
    for vault in vaults.values():
        vault.pop("open", None)
    clave = hashlib.md5(ruta.encode()).hexdigest()[:16]
    vaults[clave] = {"path": ruta, "ts": int(time.time() * 1000), "open": True}
os.makedirs(os.path.dirname(config), exist_ok=True)
with open(config, "w", encoding="utf-8") as archivo:
    json.dump(datos, archivo, indent=2)
PY
}

vault_instalar() {
  local ruta
  ruta="$(vault_ruta)"
  if [[ "$CL_SIMULAR" == "1" ]]; then
    printf '    [simulación] crear vault en %s\n' "$ruta"
    return 0
  fi
  mkdir -p "$ruta"
  # --update=none respeta lo que el estudiante ya escribió al repetir la instalación.
  cp -R --update=none "$CL_RAIZ/plantillas/vault/." "$ruta/"
  _vault_registrar "$ruta"
  ok "Vault listo en $ruta"
}

vault_verificar() {
  local ruta
  ruta="$(vault_ruta)"
  [[ -f "$ruta/Inicio.md" && -d "$ruta/Plantillas" ]] &&
    grep -qF "\"path\": \"$ruta\"" "${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/obsidian.json" 2>/dev/null
}

# El vault es trabajo del estudiante: nunca se borra.
vault_desinstalar() {
  aviso "El vault se conserva en $(vault_ruta). Bórralo a mano si ya no lo necesitas."
}

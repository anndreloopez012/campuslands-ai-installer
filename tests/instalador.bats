#!/usr/bin/env bats
# Pruebas rápidas de la lógica: no instalan nada ni necesitan permisos.

setup() {
  RAIZ="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export CL_RAIZ="$RAIZ"
  export HOME="$BATS_TEST_TMPDIR/casa"
  export XDG_CONFIG_HOME="$HOME/.config"
  mkdir -p "$HOME"
  # shellcheck source=lib/comun.sh
  . "$RAIZ/lib/comun.sh"
  # shellcheck source=lib/sistema.sh
  . "$RAIZ/lib/sistema.sh"
  # shellcheck source=modulos/vault.sh
  . "$RAIZ/modulos/vault.sh"
}

os_release() {
  export CL_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"
  printf 'ID=%s\nVERSION_ID="%s"\n' "$1" "$2" >"$CL_OS_RELEASE"
}

@test "lee la versión de os-release" {
  os_release ubuntu 24.04
  [ "$(leer_os_release VERSION_ID)" = "24.04" ]
}

@test "acepta solo las Ubuntu soportadas" {
  ubuntu_soportada 24.04
  ubuntu_soportada 26.04
  run ubuntu_soportada 22.04
  [ "$status" -ne 0 ]
}

@test "rechaza otra distribución" {
  os_release debian 13
  run comprobar_sistema 0
  [ "$status" -eq 1 ]
  [[ "$output" == *"Ubuntu"* ]]
}

@test "rechaza una Ubuntu sin soporte" {
  os_release ubuntu 22.04
  run comprobar_sistema 0
  [ "$status" -eq 1 ]
  [[ "$output" == *"22.04"* ]]
}

@test "la huella incorrecta borra la descarga" {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat >"$BATS_TEST_TMPDIR/bin/curl" <<'E'
#!/usr/bin/env bash
while (($#)); do [[ "$1" == "-o" ]] && echo falso >"$2"; shift; done
E
  chmod +x "$BATS_TEST_TMPDIR/bin/curl"
  PATH="$BATS_TEST_TMPDIR/bin:$PATH" run descargar https://x.invalid/a "$BATS_TEST_TMPDIR/a" 0000
  [ "$status" -eq 1 ]
  [ ! -e "$BATS_TEST_TMPDIR/a" ]
}

@test "no vuelve a descargar lo que ya coincide" {
  echo hola >"$BATS_TEST_TMPDIR/a"
  PATH="/nada:$PATH" run descargar https://x.invalid/a "$BATS_TEST_TMPDIR/a" "$(sha256_de "$BATS_TEST_TMPDIR/a")"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Ya estaba"* ]]
}

@test "el vault se crea y se registra" {
  export CL_VAULT="$HOME/Mi Vault"
  vault_instalar
  vault_verificar
  [ -f "$CL_VAULT/Plantillas/Clase.md" ]
}

@test "repetir respeta las notas del estudiante" {
  export CL_VAULT="$HOME/Mi Vault"
  vault_instalar
  echo "mi versión" >"$CL_VAULT/Inicio.md"
  vault_instalar
  [ "$(cat "$CL_VAULT/Inicio.md")" = "mi versión" ]
}

@test "registrar conserva otros vaults" {
  mkdir -p "$XDG_CONFIG_HOME/obsidian"
  echo '{"vaults":{"abc":{"path":"/otro","ts":1,"open":true}},"tema":"x"}' >"$XDG_CONFIG_HOME/obsidian/obsidian.json"
  export CL_VAULT="$HOME/Mi Vault"
  vault_instalar
  grep -q '"/otro"' "$XDG_CONFIG_HOME/obsidian/obsidian.json"
  grep -q '"tema"' "$XDG_CONFIG_HOME/obsidian/obsidian.json"
}

@test "la ayuda funciona sin permisos" {
  run bash "$RAIZ/install.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--verificar"* ]]
}

@test "rechaza un módulo desconocido" {
  run bash "$RAIZ/install.sh" --solo inventado
  [ "$status" -eq 1 ]
  [[ "$output" == *"desconocido"* ]]
}

@test "--omitir quita el módulo y deja los demás" {
  run bash "$RAIZ/install.sh" --omitir chatgpt --simular --forzar
  [[ "$output" != *"chatgpt_"* ]]
  [[ "$output" == *"Antigravity"* ]]
}

@test "la simulación recorre todos los módulos" {
  run bash "$RAIZ/install.sh" --simular --forzar
  [ "$status" -eq 0 ]
  [[ "$output" == *"chatgpt_"* ]]
  [[ "$output" == *"Antigravity.tar.gz"* ]]
  [[ "$output" == *"Vault"* ]]
}

@test "un módulo que falla a mitad se reporta como fallo" {
  sed -n '/^# set -e no actúa/,/^}/p' "$RAIZ/install.sh" >"$BATS_TEST_TMPDIR/correr.sh"
  cat >>"$BATS_TEST_TMPDIR/correr.sh" <<'E'
set -e
modulo_roto() {
  false
  touch "$MARCA"
}
correr_modulo modulo_roto
echo "estado=$CL_ESTADO"
E
  MARCA="$BATS_TEST_TMPDIR/marca" run bash "$BATS_TEST_TMPDIR/correr.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "estado=1" ]
  [ ! -e "$BATS_TEST_TMPDIR/marca" ]
}

@test "no hay huellas pendientes en las versiones" {
  run grep -q PENDIENTE "$RAIZ/config/versiones.conf"
  [ "$status" -ne 0 ]
}

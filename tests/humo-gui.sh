#!/usr/bin/env bash
# Abre cada app en una pantalla virtual y exige que dibuje una ventana.
# --no-sandbox es solo para el contenedor; en un equipo real no se usa.
set -uo pipefail

SALIDA="${1:-/tmp/humo}"
mkdir -p "$SALIDA"
export DISPLAY=:99
Xvfb :99 -screen 0 1280x800x24 >/dev/null 2>&1 &
XVFB=$!
sleep 2
fallos=0

probar() {
  local nombre="$1" binario="$2" pid ventana=""
  "$binario" --no-sandbox --disable-gpu >"$SALIDA/$nombre.log" 2>&1 &
  pid=$!
  for _ in $(seq 1 45); do
    ventana="$(xdotool search --onlyvisible --name '.+' 2>/dev/null | head -1)"
    [[ -n "$ventana" ]] && break
    sleep 2
  done
  if [[ -n "$ventana" ]]; then
    sleep 12
    import -window root "$SALIDA/$nombre.png" 2>/dev/null
    echo "OK    $nombre abrió ventana: $(xdotool getwindowname "$ventana" 2>/dev/null)"
  else
    echo "FALLO $nombre no abrió ventana"
    tail -5 "$SALIDA/$nombre.log"
    fallos=$((fallos + 1))
  fi
  kill "$pid" 2>/dev/null
  pkill -f "$binario" 2>/dev/null
  sleep 3
}

probar chatgpt "$(command -v chatgpt)"
probar antigravity /opt/antigravity/antigravity
probar obsidian /opt/Obsidian/obsidian
kill "$XVFB" 2>/dev/null
exit "$fallos"

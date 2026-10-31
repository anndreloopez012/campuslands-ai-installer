#!/usr/bin/env bash
# ChatGPT Desktop: paquete oficial de OpenAI. Incluye Codex gráfico.

CHATGPT_URL_BASE="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest"

chatgpt_nombre() { echo "ChatGPT Desktop + Codex gráfico"; }

chatgpt_instalado() {
  dpkg-query -W -f='${Status}' chatgpt 2>/dev/null | grep -q 'ok installed'
}

chatgpt_instalar() {
  if chatgpt_instalado; then
    # El paquete dejó configurado el repositorio firmado de OpenAI.
    apt_root install -y --only-upgrade chatgpt
    return 0
  fi
  local paquete="$CL_CACHE/chatgpt_${CL_ARQ}.deb"
  info "Descargando ChatGPT (unos 500 MB)"
  descargar "$CHATGPT_URL_BASE/chatgpt_${CL_ARQ}.deb" "$paquete"
  if [[ "$CL_SIMULAR" != "1" ]]; then
    [[ "$(dpkg-deb -f "$paquete" Package)" == "chatgpt" ]] || morir "El paquete descargado no es ChatGPT."
    [[ "$(dpkg-deb -f "$paquete" Maintainer)" == OpenAI* ]] || morir "El paquete no viene de OpenAI."
  fi
  apt_root install -y "$paquete"
  ejecutar rm -f "$paquete"
}

chatgpt_verificar() {
  chatgpt_instalado && tiene_comando chatgpt && [[ -f /usr/share/applications/chatgpt.desktop ]]
}

chatgpt_version() { dpkg-query -W -f='${Version}' chatgpt 2>/dev/null; }

chatgpt_desinstalar() {
  chatgpt_instalado && apt_root purge -y chatgpt
  return 0
}

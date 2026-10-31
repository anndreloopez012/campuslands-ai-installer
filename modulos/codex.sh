#!/usr/bin/env bash
# Codex CLI: instalador oficial de OpenAI, por usuario en ~/.local/bin.

CODEX_URL_INSTALADOR="https://chatgpt.com/codex/install.sh"

codex_nombre() { echo "Codex CLI"; }

codex_instalado() { [[ -x "$HOME/.local/bin/codex" ]]; }

codex_instalar() {
  CODEX_NON_INTERACTIVE=1 ejecutar_script_oficial "$CODEX_URL_INSTALADOR" sh
}

codex_verificar() { codex_instalado && "$HOME/.local/bin/codex" --version >/dev/null 2>&1; }

codex_version() { "$HOME/.local/bin/codex" --version 2>/dev/null | awk '{print $NF}'; }

codex_desinstalar() {
  ejecutar rm -f "$HOME/.local/bin/codex" "$HOME/.local/bin/codex-code-mode-host"
  ejecutar rm -rf "$HOME/.codex/packages"
}

# Instrucciones para agentes

Proyecto: instalador en Bash de ChatGPT Desktop, Codex CLI, Google Antigravity y Obsidian para Ubuntu 24.04 y 26.04 Desktop.

## Si te piden instalarlo

1. Comprueba que estás en Ubuntu Desktop 24.04 o 26.04.
2. Ejecuta `./install.sh` con el usuario normal, nunca como root.
3. Ejecuta `./install.sh --verificar`.
4. Indica a la persona qué cuentas debe conectar. Nunca inicies sesión por ella.

## Si te piden cambiarlo

Sigue [CONTRIBUTING.md](CONTRIBUTING.md). Lo esencial:

- Solo fuentes oficiales, sin extensiones ni reempaquetados.
- Rama por cambio desde `dev`, con `merge --no-ff` en `dev` y en `main`.
- Commits `feat(<área>): <explicación>` o `fix(<área>): <explicación>`, en español y sin atribución a herramientas de IA.
- Antes de publicar: ShellCheck, `bats tests/instalador.bats` y `tests/ubuntu-limpio.sh`.

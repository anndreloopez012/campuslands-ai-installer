# Campuslands AI Installer

Prepara un equipo con Ubuntu Desktop para estudiar en Campuslands. Con un solo comando instala las aplicaciones oficiales de IA y Obsidian, y deja el vault listo.

## Instalación

Abre una terminal con `Ctrl + Alt + T`, pega esto y presiona Enter:

```bash
wget -qO- https://raw.githubusercontent.com/anndreloopez012/campuslands-ai-installer/main/install.sh | bash
```

Se ejecuta con tu usuario normal, sin `sudo`. Te pedirá tu contraseña una vez y tarda entre 10 y 30 minutos, según tu internet. Necesitas Ubuntu 24.04 o 26.04 Desktop y 8 GB libres.

¿Primera vez? Sigue la [guía de instalación](docs/guia-instalacion.md) paso a paso.

## Qué instala

| Programa | Para qué sirve | Origen |
|---|---|---|
| **ChatGPT Desktop** | Asistente de IA de OpenAI. Trae **Codex gráfico** por dentro. | `.deb` oficial en vista previa |
| **Codex CLI** | Codex desde la terminal, con el comando `codex`. | Instalador oficial de OpenAI |
| **Google Antigravity** | Desarrollo con agentes de Google: la App de escritorio y el comando `agy`. | Archivos oficiales de Google |
| **Obsidian** | Notas en Markdown para guardar lo que aprendes. | Paquete oficial |

También crea:

- **Vault de Obsidian** en `Documentos/Campuslands Vault`, con carpetas y plantillas.
- **Carpeta «Campuslands IA»** en el menú de aplicaciones.

No instala extensiones de navegador ni guarda tus conversaciones, y no inicia sesión por ti: cada estudiante entra con su propia cuenta.

## Opciones

```bash
./install.sh --verificar
```

| Opción | Qué hace |
|---|---|
| *(ninguna)* | Instala todo. Repetirlo actualiza sin perder nada. |
| `--verificar` | Revisa qué está instalado, sin cambiar nada. |
| `--solo chatgpt,obsidian` | Instala solo esos módulos. |
| `--omitir codex` | Instala todo menos esos módulos. |
| `--vault RUTA` | Crea el vault en otra carpeta. |
| `--simular` | Muestra lo que haría, sin cambiar nada. |
| `--desinstalar` | Quita los programas. El vault se conserva. |
| `--forzar` | Sigue en un sistema no soportado, bajo tu responsabilidad. |

Módulos: `chatgpt`, `codex`, `antigravity`, `obsidian`, `vault`, `menu`.

Lo que ocurre en cada ejecución queda en `~/.local/state/campuslands-ai-installer/instalacion.log`.

## Cómo funciona

`install.sh` revisa el equipo y luego ejecuta cada archivo de `modulos/`. Cada módulo responde lo mismo: cómo se instala, cómo se verifica y cómo se quita. Si uno falla, los demás siguen, y al repetir el comando se retoma lo pendiente.

Antigravity y Obsidian usan versiones fijadas en `config/versiones.conf`, con su huella SHA-256. Así, un archivo alterado o incompleto se rechaza antes de instalarse. ChatGPT se actualiza solo con el sistema, por el repositorio firmado que deja su paquete.

## Límites conocidos

- ChatGPT Desktop para Linux es una **vista previa** de OpenAI: puede cambiar o fallar, y Computer Use aún no existe en Linux.
- En sesiones Wayland, ChatGPT usa XWayland. El soporte nativo de Wayland es experimental.
- Antigravity y Obsidian se actualizan volviendo a ejecutar el instalador, después de que se publique aquí la nueva versión.

## Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md). El diseño completo está en la [especificación](docs/especificacion.md).

## Licencia

El código de este proyecto usa la licencia [MIT](LICENSE). Cada programa instalado conserva su propia licencia y sus términos de uso.

## Instalar con una IA

Dale esta URL a Claude Code, Codex o Antigravity en el equipo Ubuntu y pídele: «instala esto». Las instrucciones para agentes están en [AGENTS.md](AGENTS.md).

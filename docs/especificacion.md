# Especificación

## Objetivo

Dejar un equipo con Ubuntu Desktop listo para un estudiante de Campuslands con un solo comando: los programas oficiales de IA, Obsidian, un vault con estructura y plantillas, y el menú de aplicaciones.

## Alcance

**Incluye:** ChatGPT Desktop con Codex gráfico, Codex CLI, Antigravity App, Antigravity CLI, Obsidian, vault y carpeta de menú.

**No incluye:** extensiones de navegador, captura de conversaciones, Antigravity IDE, inicio de sesión automático ni otros programas.

## Requisitos

- Ubuntu 24.04 o 26.04 Desktop, las versiones que OpenAI declara probadas.
- Arquitectura amd64 o arm64.
- 8 GB libres: ChatGPT ocupa 1,7 GB instalado, y el resto cubre Antigravity, Obsidian y las descargas.
- Usuario normal con `sudo`. Como root se detiene, porque el vault y las CLI pertenecen al usuario.

## Fuentes oficiales

| Programa | Fuente | Integridad |
|---|---|---|
| ChatGPT | `persistent.oaistatic.com/codex-app-prod/linux/deb/latest/` | TLS, y se comprueban nombre y mantenedor del paquete. Las actualizaciones usan el repositorio apt firmado que crea el paquete. |
| Codex CLI | `chatgpt.com/codex/install.sh` | Instalador oficial; se ejecuta en modo no interactivo. |
| Antigravity App | `storage.googleapis.com/antigravity-public/antigravity-hub/` | SHA-256 fijado |
| Antigravity CLI | `antigravity.google/cli/install.sh` | Instalador oficial |
| Obsidian | Releases de `obsidianmd/obsidian-releases` | SHA-256 fijado |

## Decisiones de diseño

- **Versiones fijadas.** Una versión fijada permite comprobar la huella SHA-256 de cada archivo. Además, la API de GitHub limita a 60 consultas por hora por IP, lo que rompería un aula detrás de una sola dirección.
- **Antigravity en `/opt/antigravity`.** Google solo publica un `tar.gz`. El instalador añade el lanzador, el icono del propio paquete, el perfil AppArmor y el registro de `antigravity://`. La carpeta pertenece a root, así que la app no puede reemplazarse sola: repetir el instalador la actualiza.
- **Obsidian en ARM64.** No hay `.deb` oficial. El AppImage oficial se desempaca en `/opt/Obsidian` para no depender de FUSE.
- **Vault en la carpeta de documentos del sistema.** Se resuelve con `xdg-user-dir`, porque en español es `Documentos`.
- **Módulos independientes.** Si uno falla, los demás siguen, y repetir el comando retoma lo pendiente.
- **Arranque con `wget`.** Ubuntu Desktop no trae `curl`.

## Flujo

1. Revisa sistema, arquitectura, escritorio y espacio.
2. Pide `sudo` y lo mantiene activo durante las descargas.
3. Instala los requisitos base con apt.
4. Ejecuta los módulos en orden: `chatgpt`, `codex`, `antigravity`, `obsidian`, `vault`, `menu`.
5. Muestra los pasos de inicio de sesión.

## Pruebas

| Nivel | Herramienta | Cubre |
|---|---|---|
| Estilo | ShellCheck | Errores comunes de Bash |
| Lógica | Bats | Detección, huellas, vault y opciones |
| Sistema | `tests/ubuntu-limpio.sh` | Instalar, verificar, repetir, abrir apps y desinstalar en Ubuntu limpio |

Las pruebas de sistema no cubren el inicio de sesión ni una sesión gráfica real de GNOME. Eso se comprueba en un equipo físico antes de distribuir.

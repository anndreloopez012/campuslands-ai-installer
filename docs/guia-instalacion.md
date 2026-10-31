# Guía de instalación

Esta guía te lleva de un Ubuntu recién instalado a tu entorno de trabajo completo.

## Antes de empezar

Revisa tres cosas:

1. **Ubuntu 24.04 o 26.04 Desktop.** Compruébalo en una terminal con `lsb_release -d`.
2. **8 GB libres en disco.** Compruébalo con `df -h /`.
3. **Internet estable.** Se descarga cerca de 1 GB.

## Paso 1. Abrir la terminal

Presiona `Ctrl + Alt + T`. La terminal es la ventana donde se escriben comandos.

## Paso 2. Ejecutar el instalador

Copia este comando, pégalo con `Ctrl + Shift + V` y presiona Enter:

```bash
wget -qO- https://raw.githubusercontent.com/anndreloopez012/campuslands-ai-installer/main/install.sh | bash
```

Qué hace: `wget` descarga el instalador y `bash` lo ejecuta.

Te pedirá tu contraseña de Ubuntu. Al escribirla no se ven caracteres; es normal. Espera a que aparezca **Listo**.

## Paso 3. Cerrar sesión y volver a entrar

Así el menú y los comandos `codex` y `agy` quedan disponibles.

## Paso 4. Entrar a tus cuentas

Cada programa usa tu propia cuenta:

| Programa | Qué hacer |
|---|---|
| **ChatGPT** | Ábrelo desde el menú e inicia sesión. Codex gráfico está dentro de esta app. |
| **Antigravity** | Ábrelo e inicia sesión con Google. El navegador te regresa a la app. |
| **Codex CLI** | En la terminal, escribe `codex` e inicia sesión. |
| **Antigravity CLI** | En la terminal, escribe `agy` e inicia sesión. |
| **Obsidian** | Ábrelo. Tu vault ya está cargado y no necesita cuenta. |

## Paso 5. Comprobar que todo quedó bien

Descarga el proyecto una sola vez y revisa el estado:

```bash
wget -qO- https://raw.githubusercontent.com/anndreloopez012/campuslands-ai-installer/main/install.sh | bash -s -- --verificar
```

Cada línea con ✓ está correcta.

## Tu vault de Obsidian

Un vault es una carpeta con tus notas en archivos Markdown. El tuyo está en `Documentos/Campuslands Vault`:

| Carpeta | Qué guardas |
|---|---|
| `01 Bandeja` | Notas rápidas, sin pensar dónde van |
| `02 Clases` | Una nota por sesión |
| `03 Proyectos` | Una nota por proyecto o reto |
| `04 Recursos` | Enlaces, guías e imágenes |
| `05 IA` | Prompts que te funcionaron |
| `Plantillas` | Moldes para Clase, Proyecto, Prompt y Diario |

Para usar una plantilla, crea una nota, presiona `Ctrl + P`, escribe «Insertar plantilla» y elige una.

## Si algo falla

| Mensaje | Qué significa | Qué hacer |
|---|---|---|
| `Ubuntu X no está soportado` | Tu versión no está probada. | Usa Ubuntu 24.04 o 26.04. |
| `Hace falta Ubuntu Desktop` | Es una versión de servidor. | Instala Ubuntu Desktop. |
| `Hay X GB libres` | Falta espacio. | Libera espacio y repite. |
| `La huella SHA-256 no coincide` | La descarga está dañada o cambió. | Repite una vez. Si sigue, avisa al instructor. |
| `Quedó pendiente: ...` | Falló una parte, casi siempre por internet. | Repite el comando; retoma donde quedó. |
| No aparece la carpeta en el menú | La sesión es anterior a la instalación. | Cierra sesión y vuelve a entrar. |
| El login de Antigravity no regresa a la app | El enlace `antigravity://` no quedó registrado. | Repite el instalador con `--solo antigravity` y vuelve a intentar. |

El detalle de cada ejecución está en `~/.local/state/campuslands-ai-installer/instalacion.log`. Compártelo con tu instructor si pides ayuda.

## Desinstalar

```bash
wget -qO- https://raw.githubusercontent.com/anndreloopez012/campuslands-ai-installer/main/install.sh | bash -s -- --desinstalar
```

Tus notas se conservan. Las sesiones de tus cuentas también quedan guardadas en tu carpeta personal.

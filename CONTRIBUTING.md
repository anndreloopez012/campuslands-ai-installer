# Cómo contribuir

## Ramas

| Rama | Uso |
|---|---|
| `main` | Lo que usan los estudiantes. El comando de instalación descarga desde aquí. |
| `dev` | Integración y pruebas. |
| `feat/<tema>` | Una función nueva. |
| `fix/<tema>` | Una corrección. |
| `docs/<tema>` | Solo documentación. |

Cada cambio va en su propia rama, creada desde `dev`, y se integra con `merge --no-ff`, primero en `dev` y después en `main`:

```bash
git switch dev
git pull --ff-only
git switch -c feat/mi-cambio
```

## Commits

Usa este formato, en español:

```text
feat(modulo): explicación corta
fix(instalador): explicación corta
```

## Antes de abrir un pull request

```bash
shellcheck -x -S warning install.sh lib/*.sh modulos/*.sh scripts/*.sh tests/*.sh
bats tests/instalador.bats
```

Si tocas una instalación o una versión, prueba también en un Ubuntu limpio con Docker:

```bash
tests/ubuntu-limpio.sh 24.04 amd64
tests/ubuntu-limpio.sh 26.04 amd64
tests/ubuntu-limpio.sh 24.04 arm64
```

Esa prueba instala de verdad, verifica, repite, abre cada app en una pantalla virtual y desinstala. No prueba el inicio de sesión, que se revisa en un equipo real.

## Agregar un módulo

Crea `modulos/<nombre>.sh` con estas funciones y suma el nombre a `CL_MODULOS` en `install.sh`:

| Función | Qué hace |
|---|---|
| `<nombre>_nombre` | Devuelve el nombre visible. |
| `<nombre>_instalado` | Indica si ya está en el equipo. |
| `<nombre>_instalar` | Instala o actualiza. Debe poder repetirse sin dañar nada. |
| `<nombre>_verificar` | Comprueba que quedó completo. |
| `<nombre>_version` | Devuelve la versión instalada. |
| `<nombre>_desinstalar` | Quita el programa, nunca los datos del estudiante. |

## Reglas del proyecto

- **Solo fuentes oficiales.** Nada de reempaquetados de la comunidad, extensiones ni copias de binarios en este repositorio.
- **Versiones fijadas con huella.** Lo que no llega por apt se actualiza con `scripts/actualizar-versiones.sh`.
- **Sin credenciales.** El instalador nunca pide ni guarda cuentas o claves.
- **Sin borrar datos.** Ni instalar ni desinstalar tocan las notas del estudiante.
- **Todo en español**, salvo los nombres de programas y comandos.
- Cada cambio visible se anota en `CHANGELOG.md`.

# Feature: Android screen → OBS

Objetivo: espejar un celular Android en OBS con calidad y latencia razonables,
de forma reproducible y documentada dentro de esta base productiva.

Rama: `feat/android-screen-to-obs`

## Decisiones

- **scrcpy como camino único** (descartado iPhone Mirroring: el usuario usa Android;
  descartado `adb exec-out screenrecord | ffmpeg`: más frágil, sin ventana capturable).
- **Ventana con título estable** (`Android OBS`) vía `--window-title` para que el
  Window Capture de OBS quede bindeado por nombre y no por ID de ventana.
- **`--no-audio` por defecto**: el forwarding de audio de scrcpy necesita Android 11+
  y una captura de audio aparte en OBS. Se habilita explícito con `--with-audio`.
- **Sin scene collection JSON de OBS**: el formato es frágil y liga IDs de ventana
  efímeros. Se documenta el flujo manual (Window Capture + fondo).

## Tasks

- [x] T1 — Instalar `scrcpy` (5.0.1) y validar flags contra la versión instalada.
- [x] T2 — Crear `share-android.sh` (ventana estable, detección de device, wireless).
- [x] T3 — Agregar `scrcpy` al `Brewfile`.
- [x] T4 — Documentar el flujo en `SETUP.md` (+ mención en `README.md`).
- [x] T5 — Validar: sintaxis, vector de argumentos con stubs, readback de docs.
- [x] T6 — Commit de work unit en la rama.

## Evidencia

- Work unit commit: `d290667` — `feat(obs): mirror Android into OBS via scrcpy helper`.
- `scrcpy 5.0.1` instalado (deps: ffmpeg). Flags confirmados con `scrcpy --help`:
  `--window-title`, `-m/--max-size`, `--max-fps`, `-w/--stay-awake`, `-n/--no-control`,
  `-s/--serial`, `--no-audio`, `-S/--turn-screen-off`.
- `adb` presente vía cask `android-platform-tools`; daemon arranca OK.
- Al momento del setup no había device conectado (`adb devices` vacío).

### Validación del script (sin device físico)

Se validó el vector de argumentos con stubs de `adb` y `scrcpy` en `/tmp/fakebin`:

| Caso | Resultado |
|---|---|
| default | `--window-title=Android OBS --max-size=1080 --max-fps=60 --stay-awake --no-audio` |
| `--view-only --with-audio` | agrega `--no-control`, omite `--no-audio` |
| `--serial DEF456` + `MAX_SIZE=720 MAX_FPS=30` | `--max-size=720 --max-fps=30 --serial=DEF456` |
| dos devices sin `--serial` | aborta listando seriales, exit 1 |
| `--wireless host:5555` | `adb connect` y sigue |

Además: `bash -n` limpio, `--help` exit 0, `--bogus` exit 1, y sin device
imprime el checklist y aborta sin lanzar `scrcpy`.
`shellcheck` no está instalado en la máquina: no se corrió (no se inventó lint).

## Pendiente fuera del repo

- Conectar el celular, aceptar el popup de depuración USB y correr `./share-android.sh`.
- En OBS: permiso *Screen Recording* + Window Capture sobre la ventana `Android OBS`.

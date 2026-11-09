# SETUP — guía paso a paso

Walkthrough completo para dejar una Mac nueva con esta base productiva.
Tiempo estimado: **30-45 minutos** (la mayoría es esperar instalaciones).

## Pre-requisitos

- Mac con macOS 14+ (Sonoma o más nuevo)
- Cuenta de GitHub propia
- Una hora libre

---

## Paso 1 — Instalar Homebrew

Homebrew es el package manager. Sin esto, nada funciona.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

El instalador te va a pedir tu password de la Mac (es para sudo). Tarda unos minutos.

**Verificar**:

```bash
brew --version
# debe imprimir algo tipo: Homebrew 4.x.x
```

Si `brew` no se reconoce, abrí una terminal nueva.

---

## Paso 2 — Generar SSH key propia

Esta llave es tuya, personal, e intransferible. Sirve para 3 cosas:

1. Autenticarte con GitHub al pushear
2. Firmar tus commits (signing)
3. Conectarte a otros servidores SSH

```bash
ssh-keygen -t ed25519 -C "tu@email.com"
```

- Cuando pregunta dónde guardar: enter (default `~/.ssh/id_ed25519`)
- Cuando pregunta passphrase: **poné una** (la guardamos en Keychain después, no la vas a tipear)

**Cargar la llave al ssh-agent con Keychain**:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Te pide la passphrase UNA vez y queda guardada en macOS Keychain. Próximas veces no te la pide más.

---

## Paso 3 — Configurar GitHub

Instalá `gh` (CLI oficial de GitHub):

```bash
brew install gh
```

Login (te abre el browser):

```bash
gh auth login
```

Seguí los prompts: GitHub.com → SSH → confirma email.

**Subir tu llave SSH a GitHub para 2 usos** (importante: ambos):

```bash
# Para autenticarte (push/pull)
gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication --title "Mac $(hostname)"

# Para firmar commits (verificación visible en GitHub)
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing --title "Mac $(hostname) signing"
```

**Verificar que la conexión funciona**:

```bash
ssh -T git@github.com
# Debe responder: Hi <tu-usuario>! You've successfully authenticated...
```

Si te pide la passphrase, hay un problema con el ssh-agent. Volvé al paso 2.

---

## Paso 4 — Clonar este repo

```bash
git clone git@github.com:TU-USUARIO/mac-productivity-setup.git ~/dotfiles
cd ~/dotfiles
```

> Reemplazá `TU-USUARIO` por tu usuario de GitHub. Si forkeaste el repo, usá tu fork.

---

## Paso 5 — Configurar tu identidad de Git

Este script genera `~/dotfiles/git/gitconfig` con TUS datos (nombre, email) y configura SSH signing.

```bash
./setup-identity.sh
```

Te va a pedir:
- **Tu nombre**: como querés que aparezca en los commits
- **Tu email**: el mismo que usás en GitHub

**¿Por qué este paso?** El gitconfig contiene tu identidad personal. Si lo committeáramos hardcodeado, todo el que clone el repo terminaría firmando commits con TU nombre. El template tiene placeholders, este script los reemplaza.

---

## Paso 6 — Crear los symlinks

```bash
./install.sh
```

Crea los enlaces simbólicos desde `~/dotfiles/` hacia las ubicaciones que las apps esperan:

| Real | Symlink en |
|---|---|
| `~/dotfiles/zsh/zshrc` | `~/.zshrc` |
| `~/dotfiles/git/gitconfig` | `~/.gitconfig` |
| `~/dotfiles/ssh/config` | `~/.ssh/config` |
| `~/dotfiles/ghostty/config` | `~/.config/ghostty/config` |
| `~/dotfiles/starship/starship.toml` | `~/.config/starship.toml` |

Si ya tenías archivos en esas ubicaciones, los respalda con timestamp antes de reemplazar.

---

## Paso 7 — Instalar el stack completo

```bash
brew bundle --file=~/dotfiles/Brewfile
```

Esto instala:
- **CLI tools**: bat, duf, dust, eza, fd, fzf, gh, git, neovim, ripgrep, sd, starship, zellij, zoxide, zsh-autosuggestions, zsh-syntax-highlighting, bash, scrcpy, android-platform-tools
- **Apps GUI**: Ghostty, Raycast, JetBrains Mono Nerd Font

Tarda 5-15 min según tu conexión.

---

## Paso 8 — Reiniciar terminal

Cerrá tu terminal actual y abrí **Ghostty** (que recién se instaló). Vas a ver:

- Catppuccin Mocha como tema
- JetBrains Mono Nerd Font con icons
- Starship prompt mostrando branch/dir
- Autocompletion mientras tipeás (sugerencias en gris)
- `z <fragmento>` te lleva a directorios que ya visitaste (zoxide)

---

## Paso 9 — Verificación final

Probá esto:

```bash
# Test 1: aliases funcionan
ll                      # debe mostrar archivos con icons + git status

# Test 2: starship prompt
cd ~/dotfiles
# El prompt debe mostrar el branch (ej: `main`)

# Test 3: SSH signing funciona
cd ~/dotfiles
git log --show-signature -1
# Debe imprimir: Good "git" signature for tu@email.com

# Test 4: Zellij con layout de agents
agents
# Te abre 4 paneles verticales en Zellij. Ctrl+o → d para detach.
```

Si todo eso funciona — **estás listo**. La base productiva está operativa.

---

## Paso 10 — Fase 2: Claude Code + Gentle AI + herdr (opcional)

Si vas a trabajar con Claude Code siguiendo la lógica del equipo, hay un solo comando más:

```bash
cd ~/dotfiles && ./setup-claude.sh
```

**Por qué una fase aparte:** la Fase 1 es universal (cualquier persona con una Mac la quiere). La Fase 2 instala el *workflow del equipo*: Claude Code, Gentle AI con la persona Gentleman, Engram (memoria), CodeGraph (índice de código) y herdr (varios agentes a la vez). No todo el mundo lo necesita, y así el Brewfile base no se contamina.

**Qué esperar:**

1. Instala paquetes con Homebrew (`Brewfile.claude`): toma unos minutos la primera vez por Node.
2. Baja Claude Code con su installer oficial. Queda en `~/.local/bin`, que el `zshrc` ya tiene en el PATH.
3. Corre `gentle-ai install` sin preguntarte nada: ya va con el preset del equipo.
4. Instala CodeGraph y lo conecta a Claude Code.
5. Fusiona `claude/settings.team.json` en tu `~/.claude/settings.json`. Si ya tenías uno, deja un backup al lado.
6. Verifica que cada herramienta responde.

**Después, una sola vez:**

```bash
# Terminal nueva, dentro de cualquier carpeta de proyecto
claude
# Te manda al navegador para iniciar sesión. Listo, ya estás hablando con el agente.
```

Si querés ver qué haría antes de tocar nada: `./setup-claude.sh --dry-run`.

---

## Extra — Compartir el celular Android en OBS

> Opcional y personal. Nada de esto se instala con la Fase 1 ni la Fase 2: vive en `Brewfile.extras`.

Si transmitís, grabás o das una demo y necesitás mostrar el celu, el camino es
`scrcpy` (espeja el Android en una ventana nativa) + **Window Capture** de OBS.
Sin plugins propietarios y sin cables especiales.

### 1. Instalar

Ya viene en el `Brewfile`. Si querés hacerlo suelto:

```bash
brew bundle --file=~/dotfiles/Brewfile.extras   # instala scrcpy (y Cold Turkey)
brew install --cask android-platform-tools   # adb
```

### 2. Preparar el celular

1. Ajustes → Información del teléfono → tocar **Número de compilación** 7 veces
   (habilita Opciones de desarrollador)
2. Ajustes → Sistema → Opciones de desarrollador → activar **Depuración USB**
3. Conectar por USB, desbloquear la pantalla y aceptar el popup
   *¿Permitir depuración USB?* (tildá "recordar")

```bash
adb devices
# tiene que listar tu device con estado "device" (no "unauthorized")
```

### 3. Espejar

```bash
cd ~/dotfiles
./share-android.sh
```

Abre una ventana titulada **Android OBS**. Flags que usa y por qué:

| Flag | Para qué |
|---|---|
| `--window-title="Android OBS"` | Título fijo → la fuente de OBS queda bindeada por nombre, no por ID de ventana |
| `--max-size=1080` | Suficiente para 1080p, menos CPU y menos bitrate |
| `--max-fps=60` | Animaciones fluidas |
| `--stay-awake` | Evita que el celu duerma y congele el espejo |
| `--no-audio` | El audio del celu se maneja aparte (ver punto 5) |

Variantes:

```bash
./share-android.sh --view-only                  # no inyecta mouse/teclado en el celu
./share-android.sh --with-audio                 # audio del device (Android 11+)
./share-android.sh --serial ABC123              # varios devices conectados
./share-android.sh --wireless 192.168.0.42:5555 # sin cable
```

Inalámbrico (Android 11+): la primera vez por USB, después

```bash
adb pair <ip>:<puerto>   # puerto y código salen en Depuración inalámbrica
./share-android.sh --wireless <ip>:5555
```

### 4. Capturarlo en OBS (una sola vez)

1. **Permiso de macOS**: System Settings → Privacy & Security → **Screen Recording** →
   tildá OBS. Sin esto el Window Capture sale **negro** y OBS no avisa por qué.
   Después de tildarlo, cerrá OBS y abrilo de nuevo.
2. En OBS: **Sources → + → Window Capture** — elegí el que dice
   *macOS Screen Capture* (el legacy no captura ventanas ocluidas).
3. En **Window** elegí **Android OBS**.
4. Aspect ratio: el celu es ~9:19.5 y el canvas 16:9. Dejá la fuente con
   `Ctrl+S` → **Fit to screen** y poné un fondo (Color Source o Image) debajo.
   No uses Display Capture: te estira el celu o te deja bandas negras.

### 5. Audio del celular (opcional)

`scrcpy` manda el audio del device a la Mac. Para que suene en OBS:

- Corré `./share-android.sh --with-audio`
- En OBS agregá **Audio Output Capture** y elegí la salida donde suena el celu

Alternativa sin forwarding: sacar el audio del celu por un cable al mixer que ya uses.

### 6. El celu como cámara de reunión

OBS → **Start Virtual Camera**, y en Meet/Zoom elegís "OBS Virtual Camera".

### Troubleshooting del espejo

- **`adb devices` muestra `unauthorized`** → desbloqueá el celu y aceptá el popup.
  Si el popup no aparece: `adb kill-server && adb devices`.
- **La ventana se ve negra en OBS** → falta el permiso de Screen Recording (punto 4.1).
- **Se congela la imagen** → el celu se durmió o apagó la pantalla por ahorro de energía.
- **Apps de video se ven negras** → bloqueo de contenido protegido (DRM). No es el setup.
- **Va lento** → `MAX_SIZE=720 MAX_FPS=30 ./share-android.sh`.

---

## Próximos pasos (opcionales)

### Personalizar tu Raycast

Raycast ya está instalado. Abrilo (`⌘ + Space`) y configuralo:

1. Asignar el hotkey de invocación (default `⌘ + Space` reemplaza Spotlight)
2. **Script Commands → Add Script Directory** → seleccioná `~/dotfiles/raycast/`
3. Agregá tus propios scripts en ese directorio (mirá `raycast/README.md`)

### Configurar Neovim

Esta base solo instala Neovim. Para una experiencia tipo IDE, podés:

- Empezar con **LazyVim** (https://www.lazyvim.org/) — config completa pre-armada
- O configurar uno propio en `~/.config/nvim/`

### Instalar más herramientas

Cuando necesites algo nuevo:

```bash
brew install <paquete>
brewdump   # vuelca tu inventario a Brewfile.local (ignorado por git); el Brewfile del equipo se edita a mano
```

Después commiteá:

```bash
cd ~/dotfiles
git add Brewfile
git commit -m "chore: agregar <paquete>"
git push
```

---

## Troubleshooting

### "command not found: brew"

Abrí una terminal nueva. Homebrew se agrega al PATH al final del install.

### "command not found: rg" / "ll"

Faltó correr `brew bundle` o todavía no reiniciaste la terminal.

### `ssh -T git@github.com` pide passphrase

El ssh-agent no tiene la llave cargada. Corré:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Commits no aparecen como "Verified" en GitHub

Verificá que subiste la llave **también como signing** (no solo authentication):

```bash
gh ssh-key list | grep -i signing
```

Si no aparece:

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing
```

### Ghostty se ve sin icons

La fuente Nerd Font necesita el sufijo "Mono". Verificá que en Ghostty config esté:

```
font-family = JetBrainsMono Nerd Font Mono
```

(no "JetBrainsMono Nerd Font" — falta el "Mono" al final)

### Quiero cambiar mi identidad de git

Re-corré `setup-identity.sh`. Sobrescribe el gitconfig con los nuevos datos:

```bash
cd ~/dotfiles && ./setup-identity.sh
```

---

## Lecciones aprendidas (gotchas)

Cosas que parecen obvias pero te hacen perder horas:

- **Ghostty `scrollback-limit` está en BYTES**, no líneas. 100_000_000 = 100 MB ≈ 1.25M líneas.
- **Themes de Ghostty usan espacios y mayúsculas** (`Catppuccin Mocha`, no `catppuccin-mocha`)
- **Nerd Fonts necesitan el sufijo "Mono"** para alineación de icons en terminal
- **`macos-option-as-alt = true`** es requisito para que Alt+letra funcione en TUI apps (zellij, lazygit, etc.)
- **Apple trae bash 3.2 ancestral** — la mayoría de scripts modernos requieren bash 5+. Por eso instalamos `bash` por brew.
- **Apple trae git viejo** — el de brew (2.40+) tiene mejores diff defaults y soporte de SSH signing por defecto.

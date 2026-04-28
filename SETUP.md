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
- **CLI tools**: bat, duf, dust, eza, fd, fzf, gh, git, neovim, ripgrep, sd, starship, zellij, zoxide, zsh-autosuggestions, zsh-syntax-highlighting, bash
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
brewdump   # actualiza tu Brewfile automáticamente
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

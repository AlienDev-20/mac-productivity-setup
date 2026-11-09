# mac-productivity-setup

> Setup productivo reproducible para Mac. De `0` a una Mac lista para trabajar en **menos de 30 minutos**.

Terminal moderna, shell con superpoderes, prompt informativo, git con commits firmados, y todas las herramientas modernas de CLI que reemplazan a las viejas. Una sola fuente de verdad — todas las configs viven en este repo, simlinkeadas a sus ubicaciones de sistema.

## ⚡ Quick Start (8 pasos)

Los comandos están en orden — copialos y pegalos uno por uno. Si algo falla, mirá la sección [Troubleshooting](#troubleshooting) más abajo.

```bash
# 1. Instalar Homebrew (package manager de Mac)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Generar tu SSH key (poné una passphrase cuando pregunte)
ssh-keygen -t ed25519 -C "tu@email.com"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# 3. Login a GitHub + subir tu llave pública (auth + signing)
brew install gh
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --type authentication --title "Mac $(hostname)"
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing --title "Mac $(hostname) signing"

# 4. Clonar este repo en ~/dotfiles
git clone git@github.com:AlienDev-20/mac-productivity-setup.git ~/dotfiles
cd ~/dotfiles

# 5. Setear tu identidad (te pide nombre y email — usá el de GitHub)
./setup-identity.sh

# 6. Crear los symlinks
./install.sh

# 7. Instalar todas las herramientas
brew bundle --file=Brewfile

# 8. Cerrá tu terminal vieja, abrí Ghostty (ya instalado), y disfrutá
```

**Listo.** Tu Mac quedó con una base productiva profesional.

> **¿Mac Intel?** Homebrew ya no se instala ahí. Saltá directo a **[SETUP-INTEL.md](./SETUP-INTEL.md)**: solo la Fase 2, a mano, sin Homebrew.

¿Vas a trabajar con Claude Code y la lógica del equipo? Seguí con la [Fase 2](#-fase-2--claude-code--gentle-ai--herdr):

```bash
# 9. (En Ghostty) Claude Code + Gentle AI + herdr, todo de una
cd ~/dotfiles && ./setup-claude.sh
```

## ✅ Cómo verificar que todo funciona

Después de abrir Ghostty fresh, probá esto:

```bash
ll                              # listado con icons + git status
z dotfiles                      # cd inteligente (saltás a ~/dotfiles)
git log --show-signature -1     # debe decir "Good signature"
agents                          # abre Zellij con 4 paneles para Claude Code
```

Si los 4 funcionan, **estás 100% listo**. Cualquier error → mirá [Troubleshooting](#troubleshooting).

Si corriste la Fase 2, sumá:

```bash
claude --version                # Claude Code instalado
gentle-ai review mode status    # Gentle AI responde
herdr --version                 # multiplexor de agentes
```

## 🤖 Fase 2 — Claude Code + Gentle AI + herdr

La Fase 1 deja la Mac lista. La Fase 2 deja **Claude Code trabajando como trabaja el equipo**: misma persona, mismo flujo (ODD), misma memoria persistente, mismos permisos. Un solo comando, idempotente:

```bash
cd ~/dotfiles && ./setup-claude.sh
```

Pensado para cualquier rol del equipo, no solo devs. Una PO, por ejemplo, abre Ghostty, escribe `claude` y ya está hablando con el agente con nuestras reglas cargadas.

### Qué instala

| Pieza | Para qué |
|---|---|
| **[Claude Code](https://docs.claude.com/en/docs/claude-code)** | El agente en la terminal. Installer oficial, queda en `~/.local/bin` |
| **[Gentle AI](https://github.com/Gentleman-Programming/gentle-ai)** | La lógica de trabajo del equipo: orquestador, ODD, skills, review nativo |
| **Persona Gentleman** | Output style: respuestas cortas, en español, verifica antes de afirmar |
| **Engram** | Memoria persistente entre sesiones (lo instala Gentle AI) |
| **context7** | Documentación al día de librerías, vía MCP (lo instala Gentle AI) |
| **[CodeGraph](https://www.npmjs.com/package/@colbymchenry/codegraph)** | Índice del código para que Claude entienda el proyecto sin leer todo |
| **[herdr](https://herdr.dev)** | Multiplexor de agentes: varios Claude en paralelo, worktrees, notificaciones |
| `claude/settings.team.json` | Idioma, estilo, archivos prohibidos (`.env`, llaves, keychain) y notificaciones de macOS cuando Claude termina |

### Qué NO hace

- No inicia sesión por vos: la primera vez que corrés `claude` te manda al navegador.
- No borra nada de tu `~/.claude/settings.json`: el estilo y el idioma del equipo ganan, los permisos se unen a los tuyos y los hooks solo se agregan. Si algo cambia, deja un backup con timestamp al lado.
- No toca tus proyectos. CodeGraph indexa cada repo la primera vez que Claude lo necesita.

### Día a día

```bash
claude            # arranca Claude Code en el proyecto actual
cc                # alias: retoma la última conversación (claude -c)
herdr             # varios agentes en paralelo, cada uno en su pane
gentle-ai         # TUI para ver/ajustar qué tiene instalado Gentle AI
gentle-ai sync    # después de actualizar gentle-ai con brew
```

### Si algo falla

- **`command not found: claude`** → abrí una terminal nueva. El installer deja el binario en `~/.local/bin`, que el `zshrc` ya agrega al PATH.
- **Gentle AI pregunta cosas** → el script lo corre con `--preset full-gentleman --persona gentleman`, no debería. Si pasa, elegí las mismas opciones.
- **Querés ver qué haría sin tocar nada** → `./setup-claude.sh --dry-run`.

## 📦 Qué incluye

### Apps GUI
- **[Ghostty](https://ghostty.org/)** — terminal GPU-accelerated, tema Catppuccin Mocha
- **[Raycast](https://www.raycast.com/)** — launcher (reemplazo pro de Spotlight)
- **JetBrains Mono Nerd Font** — fuente con icons para terminal

### CLI tools modernas
| Herramienta | Reemplaza a | Por qué |
|---|---|---|
| `bat` | `cat` | Syntax highlighting + paginado |
| `eza` | `ls` | Icons, git status, alineado |
| `fd` | `find` | Sintaxis intuitiva, 3-5x más rápido |
| `rg` (ripgrep) | `grep` | 10x más rápido, ignora `.gitignore` |
| `sd` | `sed` | Sintaxis simple (regex como uno espera) |
| `dust` | `du` | Visual, rápido |
| `duf` | `df` | Tabla coloreada |
| `fzf` | — | Fuzzy finder (Ctrl+R en historial, Ctrl+T para archivos) |
| `zoxide` | `cd` | Aprende tus directorios frecuentes (`z fragmento`) |

### Shell
- **Zsh** con autocompletion, syntax highlighting, sugerencias mientras tipeás
- **[Starship](https://starship.rs/)** — prompt rápido que muestra branch, status, tiempos de comandos
- Aliases listos: `ll`, `g`, `v`, `..`, `...`, `brewup`, `brewdump`

### Git profesional
- Versión moderna de git (no la vieja de Apple)
- **SSH signing automático** — cada commit firmado criptográficamente
- Aliases útiles: `git st`, `git lg`, `git last`, `git unstage`, `git amend`
- Defaults sensatos: rebase on pull, autoSetupRemote, prune fetch, conflictStyle zdiff3

### Multiplexer + multi-agent
- **[Zellij](https://zellij.dev/)** — terminal multiplexer moderno (alternativa a tmux)
- Layout pre-configurado `agents` → 4 paneles verticales para correr Claude Code en paralelo

### Editor
- **Neovim** instalado (sin config — vos elegís LazyVim, AstroNvim, o config propia)

## 🗂️ Estructura del repo

```
mac-productivity-setup/
├── README.md                    # Este archivo
├── SETUP.md                     # Walkthrough super detallado con explicaciones
├── install.sh                   # Crea symlinks
├── setup-identity.sh            # Genera tu gitconfig con tu nombre y email
├── setup-claude.sh              # Fase 2: Claude Code + Gentle AI + herdr
├── Brewfile                     # Inventario de paquetes a instalar
├── Brewfile.claude              # Paquetes de la Fase 2 (node, gentle-ai, herdr)
├── Brewfile.extras              # Opcional y personal: scrcpy (OBS) y Cold Turkey
├── claude/settings.team.json    # Settings de Claude Code compartidos por el equipo
├── claude/merge-settings.js     # Fusiona esos settings con los tuyos (lo usa SETUP-INTEL.md)
├── SETUP-INTEL.md               # Mac Intel sin Homebrew: solo la Fase 2, a mano
├── share-android.sh             # Extra opcional: espeja tu Android en una ventana para OBS
├── zsh/zshrc                    # Shell config
├── git/gitconfig.template       # Template (vos generás el real con setup-identity.sh)
├── ssh/config                   # SSH config (entry de GitHub)
├── ghostty/config               # Terminal config
├── starship/starship.toml       # Prompt config
├── zellij/layouts/agents.kdl    # Layout de 4 paneles para Claude Code
└── raycast/                     # Para tus scripts de Raycast (vacío de fábrica)
```

## 🛠️ Día a día — comandos útiles

```bash
# Navegación inteligente
z <fragment>      # cd a un dir que ya visitaste (ej: z dot → ~/dotfiles)
ll                # listado completo con git status
..                # cd ..
...               # cd ../..

# Búsqueda en archivos
rg "patron"                    # buscar texto en todo el proyecto
fd "nombre"                    # buscar archivos por nombre
bat archivo.js                 # ver con syntax highlighting

# Fuzzy finder (en cualquier momento)
Ctrl+R           # historial de comandos con fuzzy search
Ctrl+T           # buscar archivos con fuzzy search

# Multi-agent workflow (Claude Code)
cc               # retoma la última conversación de Claude (claude -c)
herdr            # multiplexor de agentes (Fase 2) — la opción recomendada
agents           # alternativa con Zellij: 4 paneles, un agent por pane
                 # Ctrl+o → d para detach (procesos siguen vivos)
                 # `agents` de nuevo para re-attach

# Mantenimiento
brewup           # update + upgrade + cleanup de Homebrew
brewdump         # vuelca tus paquetes a Brewfile.local (ignorado por git)

# Celular en OBS (solo si instalaste Brewfile.extras)
./share-android.sh             # espeja el Android en la ventana "Android OBS"

# Git
g st             # status corto
g lg             # log gráfico con branches
g last           # último commit con stats
```

## 🎨 Personalizar

Una vez que la base funciona, agregale **lo tuyo**:

### Aliases personales
Editá `zsh/zshrc` y agregá los que uses al final:
```bash
alias mi-proyecto="cd ~/Programing/mi-proyecto"
alias deploy="./scripts/deploy.sh"
```

### Más paquetes
```bash
brew install <paquete>
brewdump   # vuelca tu inventario a Brewfile.local, ignorado por git
# Si es para todo el equipo, agregalo a mano al Brewfile correspondiente
```

### Extras personales (opcional)
`Brewfile.extras` tiene lo que no es del equipo: `scrcpy` para espejar el celular en OBS y Cold Turkey para bloquear distracciones. Se instala aparte:
```bash
brew bundle --file=~/dotfiles/Brewfile.extras
```

### Scripts de Raycast
Ponelos en `raycast/` siguiendo el formato (mirá `raycast/README.md`):
```bash
# raycast/mi-script.sh
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Mi Comando
# @raycast.mode silent
# @raycast.icon 🚀

echo "Hola mundo"
```

Después en Raycast: **Script Commands → Add Script Directory** → seleccioná `~/dotfiles/raycast/`.

### Config de Neovim
Esta base solo instala el binario. Recomendado: **[LazyVim](https://www.lazyvim.org/)** para una experiencia tipo IDE.

## 🔐 Seguridad

- ✅ La llave SSH privada (`~/.ssh/id_ed25519`) **nunca** se commitea — el `.gitignore` la bloquea
- ✅ Tu identidad personal (nombre/email) **nunca** se commitea — el `gitconfig` final está en `.gitignore`, solo va al repo el `gitconfig.template`
- ✅ Todos tus commits quedan firmados con tu llave SSH automáticamente
- ✅ La passphrase de tu llave queda en macOS Keychain (no la tipeás más después del primer login)

## 🆘 Troubleshooting

### `command not found: brew`
Abrí una terminal NUEVA después de instalar Homebrew. El installer agrega `brew` al PATH al final, pero la terminal vieja no lo ve.

### `command not found: rg` / `ll`
Faltó correr `brew bundle` o no reiniciaste la terminal después.

### `ssh -T git@github.com` te pide la passphrase
El ssh-agent no tiene la llave cargada. Corré:
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### Mis commits no aparecen "Verified" en GitHub
Verificá que subiste la llave **también como signing** (no solo authentication):
```bash
gh ssh-key list | grep -i signing
```
Si no aparece:
```bash
gh ssh-key add ~/.ssh/id_ed25519.pub --type signing
```

### Ghostty se ve sin icons
La fuente Nerd Font necesita el sufijo "Mono". Verificá que en `~/.config/ghostty/config` esté:
```
font-family = JetBrainsMono Nerd Font Mono
```
(NO "JetBrainsMono Nerd Font" — falta el "Mono" al final)

### `./install.sh` se queja de que no hay gitconfig
Es que falta correr `setup-identity.sh` primero — el install.sh chequea que tu identidad esté configurada antes de hacer los symlinks.

```bash
./setup-identity.sh
./install.sh
```

### Quiero cambiar mi identidad de git
Re-corré `setup-identity.sh`:
```bash
cd ~/dotfiles && ./setup-identity.sh
```
Sobrescribe el gitconfig con los datos nuevos.

### Algo se rompió y quiero empezar de cero
El `install.sh` respalda los archivos existentes con timestamp antes de reemplazar. Buscá los `.backup.YYYYMMDD_HHMMSS` y restaurá los que quieras.

## 📚 Más info

- **[SETUP.md](./SETUP.md)** — guía paso a paso con explicaciones del POR QUÉ de cada cosa
- **[Ghostty docs](https://ghostty.org/docs)** — keybindings y opciones de la terminal
- **[Starship docs](https://starship.rs/config/)** — personalizar el prompt
- **[Zellij docs](https://zellij.dev/documentation/)** — layouts, keybindings, sessions

## 📝 Filosofía

- **CONCEPTOS > CÓDIGO** — entendé qué hace cada cosa antes de copiar/pegar
- **Reproducible** — una sola fuente de verdad, versionada en git
- **Foundations first** — el OS, el shell, el terminal son la base. Sin esto sólido, todo lo demás sufre
- **Sin atajos** — no hay forma "rápida" de tener una Mac productiva. Acá invertís 30 minutos UNA VEZ y disfrutás meses

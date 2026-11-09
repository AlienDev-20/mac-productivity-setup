# Setup en una Mac Intel (sin Homebrew)

> Desde Homebrew 7 el instalador se niega a correr en Macs Intel
> (`Homebrew on macOS is only supported on Apple Silicon processors!`).
> Esta guía arma **solo la Fase 2** (Claude Code con la lógica del equipo)
> a mano, sin Homebrew. No necesitás la Fase 1 del README.

Tiempo estimado: 20 minutos. Todo se hace en la app **Terminal** (Cmd+Espacio → "Terminal").

Vas a necesitar:
- Una cuenta de GitHub propia.
- Una cuenta de Anthropic con acceso a Claude Code (plan Pro, Max, Team o Enterprise).

Qué queda afuera en Intel y por qué: **herdr** (solo Apple Silicon) y las
CLI modernas de la Fase 1 (se instalan con Homebrew). Para usar Claude Code
no hacen falta.

## Paso 1 — Herramientas de línea de comando de Apple (git, curl)

```bash
xcode-select --install
```

Aparece una ventana: aceptá y esperá que termine (puede tardar varios minutos). Después:

```bash
git --version
```

Debe imprimir una versión. Si dice `command not found`, la instalación todavía no terminó.

## Paso 2 — Node.js

Gentle AI y CodeGraph corren sobre Node.

1. Entrá a <https://nodejs.org/en/download>.
2. Elegí **macOS Installer (.pkg)** para la versión **LTS**. Si te pregunta la arquitectura, **x64** (Intel).
3. Abrí el `.pkg` y seguí el asistente.
4. Cerrá la Terminal, abrila de nuevo y verificá:

```bash
node -v
npm -v
```

## Paso 3 — Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

No muestra progreso: esperá hasta que vuelva el prompt. Cerrá la Terminal, abrila de nuevo y:

```bash
claude --version
```

Si dice `command not found: claude`, agregá esta línea al final de `~/.zshrc` y abrí una terminal nueva:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Paso 4 — Gentle AI

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
```

Cerrá la Terminal, abrila de nuevo y:

```bash
gentle-ai --version
```

Ahora instalalo dentro de Claude Code con el preset del equipo. No pregunta nada:

```bash
gentle-ai install --agent claude-code --preset full-gentleman --persona gentleman --scope global
```

Esto deja en `~/.claude` el orquestador, el flujo ODD, las skills, la persona Gentleman, Engram (memoria persistente) y context7 (documentación al día).

## Paso 5 — CodeGraph

```bash
npm install -g @colbymchenry/codegraph
codegraph install --yes
```

## Paso 6 — Settings del equipo

Baja la configuración compartida (idioma, estilo, archivos prohibidos, notificaciones) y la fusiona con la tuya sin pisar nada:

```bash
curl -fsSL https://raw.githubusercontent.com/AlienDev-20/mac-productivity-setup/main/claude/settings.team.json -o ~/settings.team.json
curl -fsSL https://raw.githubusercontent.com/AlienDev-20/mac-productivity-setup/main/claude/merge-settings.js | node - ~/settings.team.json
rm ~/settings.team.json
```

## Paso 7 — Verificación

```bash
claude --version
gentle-ai review mode status
engram --version
codegraph --version
```

Los cuatro tienen que responder. Después, entrá a una carpeta de proyecto y:

```bash
claude
```

La primera vez te manda al navegador para iniciar sesión. Listo: ya estás hablando con el agente con las reglas del equipo.

## Opcional

- **Ghostty** como terminal: <https://ghostty.org/download> (hay build para Intel). La Terminal de Mac alcanza.
- **Identidad de git**, si vas a hacer commits:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

## Si algo falla

- **`command not found` después de instalar** → casi siempre es que falta abrir una terminal nueva.
- **`gentle-ai install` pide elegir opciones** → elegí `claude-code`, preset `full-gentleman`, persona `gentleman`.
- **`npm install -g` da error de permisos** → no uses `sudo`. Corré `mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global` y agregá `export PATH="$HOME/.npm-global/bin:$PATH"` al final de `~/.zshrc`.

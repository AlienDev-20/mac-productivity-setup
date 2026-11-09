# Setup en Windows (WSL2 + Ubuntu)

> Gentle AI no publica binario para Windows nativo. La ruta que funciona es
> **WSL2**: una Ubuntu real corriendo dentro de Windows, con su propia terminal.
> Esta guía arma **solo la Fase 2** (Claude Code con la lógica del equipo)
> dentro de esa Ubuntu. No necesitás la Fase 1 del README.

Tiempo estimado: 30 minutos más un reinicio. Requiere Windows 10 (versión 2004 o
superior) o Windows 11.

Vas a necesitar:
- Una cuenta de GitHub propia.
- Una cuenta de Anthropic con acceso a Claude Code (plan Pro, Max, Team o Enterprise).

Regla de oro: **todo lo que viene después del Paso 2 se escribe en la terminal de
Ubuntu**, nunca en PowerShell ni en CMD. La terminal de Ubuntu se reconoce por el
prompt verde que termina en `$`.

## Paso 1 — Instalar WSL2 con Ubuntu

1. Menú Inicio → escribí `PowerShell` → clic derecho → **Ejecutar como administrador**.
2. Pegá y ejecutá:

```powershell
wsl --install
```

3. Cuando termine, **reiniciá la computadora**.
4. Al volver se abre sola una ventana de Ubuntu que descomprime archivos y
   te pide un **nombre de usuario** (en minúsculas, sin espacios) y una
   **contraseña**. La contraseña no se ve mientras la escribís: es normal.
   Anotala, la vas a usar cada vez que un comando pida `sudo`.

Si `wsl --install` solo muestra un texto de ayuda, WSL ya estaba instalado. Corré
`wsl --install -d Ubuntu` en su lugar.

## Paso 2 — Abrir la terminal de Ubuntu

- **Windows 11**: abrí **Terminal** (Menú Inicio → "Terminal"). En la flecha ▾ de
  la barra de pestañas elegí **Ubuntu**. Opcional: en Configuración → Perfil
  predeterminado elegí Ubuntu para que abra ahí siempre.
- **Windows 10**: instalá **Windows Terminal** desde la Microsoft Store y hacé lo
  mismo. También podés abrir "Ubuntu" directo desde el Menú Inicio.

Verificá que estás en Ubuntu:

```bash
uname -a
```

Tiene que decir `Linux`. Si dice otra cosa o el prompt empieza con `PS C:\`,
estás en PowerShell: volvé al punto anterior.

## Paso 3 — Herramientas base (git, curl)

```bash
sudo apt update && sudo apt install -y git curl build-essential
```

Pide la contraseña del Paso 1. Después:

```bash
git --version
```

## Paso 4 — Node.js (con nvm)

Gentle AI y CodeGraph corren sobre Node. En Ubuntu lo instalamos con `nvm`, que no
necesita permisos de administrador:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.41.0/install.sh | bash
```

Cerrá la terminal, abrila de nuevo (Ubuntu) y:

```bash
nvm install --lts
node -v
npm -v
which node
```

`which node` tiene que mostrar una ruta que empiece con `/home/`. Si muestra
`/mnt/c/...`, estás usando un Node de Windows: mirá "Si algo falla".

## Paso 5 — Claude Code

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

No muestra progreso: esperá hasta que vuelva el prompt. Cerrá la terminal, abrila
de nuevo y:

```bash
claude --version
```

Si dice `command not found: claude`, agregá esta línea al final de `~/.bashrc` y
abrí una terminal nueva:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Paso 6 — Gentle AI

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
```

Cerrá la terminal, abrila de nuevo y:

```bash
gentle-ai --version
```

Ahora instalalo dentro de Claude Code con el preset del equipo. No pregunta nada:

```bash
gentle-ai install --agent claude-code --preset full-gentleman --persona gentleman --scope global
```

Esto deja en `~/.claude` el orquestador, el flujo ODD, las skills, la persona
Gentleman, Engram (memoria persistente) y context7 (documentación al día).

## Paso 7 — CodeGraph

```bash
npm install -g @colbymchenry/codegraph
codegraph install --yes
```

## Paso 8 — Settings del equipo

Baja la configuración compartida (idioma, estilo, archivos prohibidos) y la fusiona
con la tuya sin pisar nada:

```bash
curl -fsSL https://raw.githubusercontent.com/AlienDev-20/mac-productivity-setup/main/claude/settings.team.json -o ~/settings.team.json
curl -fsSL https://raw.githubusercontent.com/AlienDev-20/mac-productivity-setup/main/claude/merge-settings.js | node - ~/settings.team.json
rm ~/settings.team.json
```

Las notificaciones de escritorio de ese archivo son de macOS: en Ubuntu quedan
desactivadas en silencio. Todo lo demás aplica igual.

## Paso 9 — Verificación

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

La primera vez te muestra un link para iniciar sesión en el navegador de Windows.
Listo: ya estás hablando con el agente con las reglas del equipo.

## Dónde van los proyectos

Cloná y trabajá los repos **dentro de Ubuntu**, en tu carpeta de usuario
(`~/proyectos`, por ejemplo). Es mucho más rápido que trabajar sobre `/mnt/c/...`
(el disco de Windows visto desde Linux).

Para ver esos archivos desde el Explorador de Windows, pegá en la barra de
direcciones:

```text
\\wsl$\Ubuntu\home\TU_USUARIO
```

## Opcional

- **Identidad de git**, si vas a hacer commits:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"
```

- **herdr** tiene build para Linux y para Windows, pero no está probado dentro de
  WSL. No hace falta para empezar.

## Si algo falla

- **`command not found` después de instalar** → casi siempre es que falta abrir
  una terminal nueva (de Ubuntu).
- **El comando "no se reconoce" o aparece `PS C:\`** → estás en PowerShell. Abrí
  la pestaña de Ubuntu.
- **`which node` muestra `/mnt/c/...`** → hay un Node instalado en Windows que se
  mete en el PATH de Ubuntu. Repetí `nvm install --lts` y `nvm use --lts`; nvm se
  pone adelante en el PATH.
- **`gentle-ai install` pide elegir opciones** → elegí `claude-code`, preset
  `full-gentleman`, persona `gentleman`.
- **`npm install -g` da error de permisos** → no uses `sudo`. Con nvm no debería
  pasar; si pasa, repetí el Paso 4.
- **`wsl --install` se queda en 0.0%** → corré
  `wsl --install --web-download -d Ubuntu` en PowerShell como administrador.

# Raycast Scripts

Este directorio está pensado para alojar tus **Raycast Script Commands** personales.

## Cómo usarlo

1. Agregá tus scripts (`.sh` o `.applescript`) en este directorio
2. En Raycast: `⌘ + Space` → buscá **"Script Commands"** → **"Add Script Directory"**
3. Seleccioná `~/dotfiles/raycast/`
4. Tus scripts aparecen automáticamente como comandos en Raycast

## Formato de un script

Cada script necesita un header con metadata para que Raycast lo reconozca. Ejemplo de un script bash:

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Mi Comando
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.description Lo que hace este comando

# Tu código acá
echo "Hola mundo"
```

Y para AppleScript (útil para automatización de apps de macOS):

```applescript
#!/usr/bin/osascript

# @raycast.schemaVersion 1
# @raycast.title Mi Script AS
# @raycast.mode silent
# @raycast.icon 🍎

display notification "Hola" with title "Test"
```

## Asignar hotkeys

Una vez que el script aparezca en Raycast:
- Seleccionalo → `⌘ + K` → **Assign Hotkey**
- Sugerencia: `⌥ + ⇧ + <letra>` (Option + Shift + algo) para evitar conflictos con macOS

## Recordá

Los scripts deben ser ejecutables:

```bash
chmod +x ~/dotfiles/raycast/mi-script.sh
```

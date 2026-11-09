#!/usr/bin/env node
// merge-settings.js — fusiona settings.team.json en ~/.claude/settings.json
//
// Uso:
//   node merge-settings.js <ruta/a/settings.team.json>
//
// Reglas (las mismas que setup-claude.sh):
//   - outputStyle / language: el valor del equipo gana
//   - permissions.deny: unión, sin duplicados, respetando tu orden
//   - hooks: se agregan solo los que no existan (por comando)
// Si nada cambia, no escribe. Si cambia, deja backup con timestamp.
"use strict";
const fs = require("fs");
const os = require("os");
const path = require("path");

const teamPath = process.argv[2];
if (!teamPath) {
  console.error("Uso: node merge-settings.js <ruta/a/settings.team.json>");
  process.exit(1);
}
const settingsPath = process.env.CLAUDE_SETTINGS || path.join(os.homedir(), ".claude", "settings.json");

const team = JSON.parse(fs.readFileSync(teamPath, "utf8"));
fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
const before = fs.existsSync(settingsPath) ? fs.readFileSync(settingsPath, "utf8") : "{}";
const cur = JSON.parse(before);

cur.outputStyle = team.outputStyle;
cur.language = team.language;

cur.permissions = cur.permissions || {};
const deny = [...(cur.permissions.deny || [])];
for (const d of team.permissions.deny) if (!deny.includes(d)) deny.push(d);
cur.permissions.deny = deny;

cur.hooks = cur.hooks || {};
for (const [event, entries] of Object.entries(team.hooks)) {
  const existing = cur.hooks[event] || [];
  const known = new Set(existing.flatMap((e) => (e.hooks || []).map((h) => h.command)));
  for (const entry of entries) {
    if (!known.has(entry.hooks[0].command)) existing.push(entry);
  }
  cur.hooks[event] = existing;
}

const after = JSON.stringify(cur, null, 2) + "\n";
if (after === before) {
  console.log("✓ settings.json ya tenía todo lo del equipo (sin cambios)");
  process.exit(0);
}
let note = "";
if (fs.existsSync(settingsPath)) {
  const ts = new Date().toISOString().replace(/[-:T]/g, "").slice(0, 14);
  fs.copyFileSync(settingsPath, `${settingsPath}.backup.${ts}`);
  note = " (backup al lado con timestamp)";
}
fs.writeFileSync(settingsPath, after);
console.log(`✓ settings.json fusionado → ${settingsPath}${note}`);

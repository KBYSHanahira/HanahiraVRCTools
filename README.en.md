# HanahiraVRC

🌐 [日本語](README.md) | **English**

A one-file **VRChat fix toolkit** for Windows. Double-click `HanahiraVRC.bat` and pick a fix from the menu.

![Main menu](docs/screenshot-menu.png)

> ⚠️ Unofficial fan-made tool. Not affiliated with VRChat Inc.

## Features

| Key | Tool | What it does |
|---|---|---|
| 1 | KILL | Stop stuck VRChat / Easy Anti-Cheat processes |
| 2 | CACHE | Clear avatar & world cache (incl. HTTP / texture caches, honours custom `cache_directory` in `config.json`) |
| 3 | EAC | Repair Easy Anti-Cheat (finds the game across all Steam libraries) |
| 4 | VERIFY | Verify game files through Steam |
| 5 | OSC | Reset OSC configs |
| F | DISCORD | Disable DiscordHook (with or without closing VRChat), restore it, and reopen Discord |
| I | IME | Diagnose and fix Japanese IME input not working in VRChat |
| 6 | NET | Flush DNS + reset Winsock *(Administrator)* |
| 7 | DIAG | VRChat API status, cache size, log count |
| 8 | AUDIO | Restart Windows audio (mic / sound missing) *(Administrator)* |
| 9 | LOGS | Delete old VRChat logs |
| A / B | BACKUP / RESET | Back up / reset VRChat registry settings (always backs up first) |
| C | FOLDERS | Open data / cache / backups / logs folders |
| J | JUNK | Clean temp files, crash dumps and shader caches (previews sizes, asks before deleting) |
| D / E / S | LAUNCH / AUTOFIX / STEAM | Start VRChat (VR / Desktop), one-click cleanup, restart Steam |

## Screenshot

![DIAG screen](docs/screenshot-diag.png)

## Usage

1. Download [`HanahiraVRC.bat`](HanahiraVRC.bat).
2. Double-click it.
3. For options marked `◆` (needs Administrator), press **R** in the menu to relaunch as Administrator.

- Use a modern terminal such as **Windows Terminal** (the default on Windows 11) for colours and box drawing.
- Logs go to `Logs\HanahiraVRC.log` and registry backups to `Backups\`, next to the script.

## Safety

- Destructive actions ask for confirmation first; your documents and personal files are never touched.
- Resetting settings always makes a backup before anything is deleted.
- `JUNK` only targets temp files and caches. Emptying the Recycle Bin is a separate confirmation.

## Technical notes

- The `.bat` is a small launcher; the tool itself is PowerShell embedded in the same file.
- Keep the file saved with **CRLF** line endings (enforced by `.gitattributes`) or `cmd.exe` will misread it.

## License

[MIT](LICENSE)

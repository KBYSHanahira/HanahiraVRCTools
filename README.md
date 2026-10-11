# HanahiraVRC

A one-file **VRChat fix toolkit** for Windows. Double-click `HanahiraVRC.bat` and pick a fix from the menu (orange-on-black terminal UI).

## Features

| Key | Tool | What it does |
|---|---|---|
| 1 | KILL | Stop stuck VRChat / Easy Anti-Cheat processes |
| 2 | CACHE | Clear avatar & world cache (incl. HTTP / texture caches, honours custom `cache_directory`) |
| 3 | EAC | Repair Easy Anti-Cheat (finds the game across all Steam libraries) |
| 4 | VERIFY | Verify game files through Steam |
| 5 | OSC | Reset OSC configs |
| F | DISCORD | Disable DiscordHook (with or without closing VRChat), restore it, and reopen Discord |
| I | IME | Fix Japanese IME input not working in VRChat |
| 6 | NET | Flush DNS + reset Winsock *(Administrator)* |
| 7 | DIAG | VRChat API status, cache size, logs |
| 8 | AUDIO | Restart Windows audio *(Administrator)* |
| 9 | LOGS | Delete old VRChat logs |
| A / B | BACKUP / RESET | Back up / reset VRChat registry settings (always backs up first) |
| C | FOLDERS | Open data / cache / backups / logs folders |
| J | JUNK | Clean temp files, crash dumps and shader caches (previews first, asks before deleting) |
| D / E / S | LAUNCH / AUTOFIX / STEAM | Start VRChat, one-click cleanup, restart Steam |

## Usage

1. Download `HanahiraVRC.bat`.
2. Double-click it. Press **R** in the menu to relaunch as Administrator when an option needs it.
3. Use a modern terminal (Windows Terminal, default on Windows 11) for colours and box drawing.

Logs go to `Logs\HanahiraVRC.log` and registry backups to `Backups\`, next to the script.

## Notes

- Destructive actions ask for confirmation; nothing touches your documents.
- The `.bat` is a small launcher; the tool itself is PowerShell embedded in the same file.
- Keep the file saved with **CRLF** line endings (enforced by `.gitattributes`) or `cmd.exe` will misread it.

## License

[MIT](LICENSE)

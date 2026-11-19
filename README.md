<p align="center">
  <img src="logo.svg" alt="CLM" width="452">
</p>

<p align="center">A keyboard-driven terminal launcher for Claude Code.<br>Browse local projects, search chats, and open a new or existing session in the selected folder.</p>

## Requirements

- macOS, Linux, or Windows 10/11
- Python 3.9 or newer (on Windows the installer adds the `windows-curses` package)
- Claude Code installed and available as `claude` on your PATH

## Install

### macOS and Linux

One line, no clone needed:

```sh
curl -fsSL https://raw.githubusercontent.com/Sl0oth/claude-menu/main/install.sh | sh
```

Or from a clone (updates with `git pull`):

```sh
git clone https://github.com/Sl0oth/claude-menu.git
cd claude-menu
./install.sh
```

Either way `clm` lands in `~/.local/bin` (set `CLM_BIN_DIR` to change that), and that folder is added to your PATH if it isn't already. To remove it: `./install.sh --uninstall` from a clone, or `curl -fsSL https://raw.githubusercontent.com/Sl0oth/claude-menu/main/install.sh | sh -s -- --uninstall`.

### Windows

In PowerShell:

```powershell
irm https://raw.githubusercontent.com/Sl0oth/claude-menu/main/install.ps1 | iex
```

Or from a clone:

```powershell
git clone https://github.com/Sl0oth/claude-menu.git
cd claude-menu
powershell -ExecutionPolicy Bypass -File install.ps1
```

This installs `windows-curses` if needed, puts `clm` in `%LOCALAPPDATA%\clm` (set `CLM_INSTALL_DIR` to change that), and adds it to your user PATH. Open a new terminal afterwards. To remove it: `powershell -ExecutionPolicy Bypass -File install.ps1 -Uninstall` from a clone, or in PowerShell: `& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Sl0oth/claude-menu/main/install.ps1))) -Uninstall`.

Then run `clm` from any folder.

## Update

```sh
clm --update
```

That downloads the latest version (or runs `git pull` if you installed from a clone). About once a day clm checks for a new version in the background and shows **update available** in the status bar when there is one. Set `CLM_NO_UPDATE_CHECK` to any non-empty value to turn the check off.

## Use

- Type to search.
- Use **↑ / ↓** to move and **Enter** to open.
- Press **Esc** to clear the search or go back, and **Ctrl-C** to quit.
- Folders end in `/`. Choose **New chat** to start a session.

Run `clm` from any folder and it opens on that folder: **New chat** to start a session right there, its subfolders, and its Claude Code chats. Folders show how many chats are inside them, nested ones included. Search looks through every level below. Run it from `~` to see everything. It reads session metadata locally from `~/.claude/projects`, or from `$CLAUDE_CONFIG_DIR/projects` when set. It opens Claude Code directly with `claude` for a new chat or `claude --resume <session-id>` for an existing chat. When Claude Code exits, CLM returns to the menu.

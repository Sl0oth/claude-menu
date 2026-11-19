<p align="center">
  <img src="logo.svg" alt="CLM" width="452">
</p>

<p align="center">A keyboard-driven terminal launcher for Claude Code.<br>Browse local projects, search chats, and open a new or existing session in the selected folder.</p>

## Requirements

- macOS and Python 3 with curses
- Claude Code installed and available as `claude` on your PATH

## Install

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

Either way `clm` lands in `~/.local/bin` (set `CLM_BIN_DIR` to change that), and that folder is added to your PATH if it isn't already. Then run `clm` from anywhere. To remove it: `./install.sh --uninstall`.

## Update

```sh
clm --update
```

That downloads the latest version (or runs `git pull` if you installed from a clone). About once a day clm checks for a new version in the background and shows **update available** in the status bar when there is one. Set `CLM_NO_UPDATE_CHECK=1` to turn the check off.

## Use

- Type to search.
- Use **↑ / ↓** to move and **Enter** to open.
- Press **Esc** to clear the search or go back, and **Ctrl-C** to quit.
- Folders end in `/`. Choose **New chat** to start a session.

Run `clm` from any folder and it opens on that folder: **New chat** to start a session right there, its subfolders, and its Claude Code chats. Folders show how many chats are inside them, nested ones included. Search looks through every level below. Run it from `~` to see everything. It reads session metadata locally from `~/.claude/projects`, or from `$CLAUDE_CONFIG_DIR/projects` when set. It opens Claude Code directly with `claude` for a new chat or `claude --resume <session-id>` for an existing chat. When Claude Code exits, CLM returns to the menu.

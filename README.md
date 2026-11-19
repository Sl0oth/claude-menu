# CLM

CLM is a keyboard-driven terminal launcher for Claude Code. Browse local projects, search chats, and open a new or existing session in the selected folder.

## Requirements

- macOS and Python 3 with curses
- Claude Code installed and available as `claude` on your PATH

## Install

One line, no clone needed:

```sh
curl -fsSL https://raw.githubusercontent.com/Sl0oth/clm/main/install.sh | sh
```

Or from a clone (updates with `git pull`):

```sh
git clone https://github.com/Sl0oth/clm.git
cd clm
./install.sh
```

Either way `clm` lands in `~/.local/bin` (set `CLM_BIN_DIR` to change that), and that folder is added to your PATH if it isn't already. Then run `clm` from anywhere. To remove it: `./install.sh --uninstall`.

## Use

- Type to search.
- Use **↑ / ↓** to move and **Enter** to open.
- Press **Esc** to clear the search or go back, and **Ctrl-C** to quit.
- Folders end in `/`. Choose **New chat** to start a session.

CLM shows projects from your local Claude Code history and lets you search top-level folders in `~/Documents/Dev`. It reads session metadata locally from `~/.claude/projects`, or from `$CLAUDE_CONFIG_DIR/projects` when set. It opens Claude Code directly with `claude` for a new chat or `claude --resume <session-id>` for an existing chat. When Claude Code exits, CLM returns to the menu.

# CLM

CLM is a keyboard-driven terminal launcher for Claude Code. Browse local projects, search chats, and open a new or existing session in the selected folder.

## Requirements

- macOS and Python 3 with curses
- Claude Code installed and available as `claude` on your PATH

## Run

From this folder:

```sh
./clm
```

To run `clm` from anywhere, place the executable or a symlink to it in a directory on your PATH.

- Type to search.
- Use **↑ / ↓** to move and **Enter** to open.
- Press **Esc** to clear the search or go back, and **Ctrl-C** to quit.
- Folders end in `/`. Choose **New chat** to start a session.

CLM shows projects from your local Claude Code history and lets you search top-level folders in `~/Documents/Dev`. It reads session metadata locally from `~/.claude/projects`, or from `$CLAUDE_CONFIG_DIR/projects` when set. It opens Claude Code directly with `claude` for a new chat or `claude --resume <session-id>` for an existing chat. When Claude Code exits, CLM returns to the menu.

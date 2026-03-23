# cmux-tmux-shim

Enables **Claude Code agent teams split-pane mode** inside [cmux](https://github.com/manaflow-ai/cmux).

Claude Code's `--teammate-mode tmux` only supports tmux and iTerm2. This shim intercepts tmux commands and translates them to cmux CLI equivalents, so agent teams spawn teammates as visible split panes.

## How it works

```
Claude Code calls:          Shim translates to:
tmux split-window -h    →   cmux new-split right
tmux send-keys -t %1    →   cmux send --surface surface:N
tmux kill-pane -t %1    →   cmux close-surface --surface surface:N
tmux capture-pane -t %1 →   cmux capture-pane --surface surface:N
tmux list-panes         →   Returns only mapped panes (no tab leaks)
```

The shim maintains a `%N → cmux surface` ID mapping so all commands target the correct cmux surfaces. Works with both surface refs (`surface:N`) and UUIDs.

## Requirements

- [cmux](https://github.com/manaflow-ai/cmux) (macOS)
- [Claude Code](https://claude.com/claude-code) with agent teams enabled
- fish or zsh shell

## Install

```bash
git clone https://github.com/ogallotti/cmux-tmux-shim.git
cd cmux-tmux-shim
bash install.sh
```

The installer:
1. Copies the shim to `~/.local/bin/tmux`
2. Detects your shell (fish/zsh)
3. Offers to add the config to your shell rc file

## Manual install

1. Copy `bin-tmux` to `~/.local/bin/tmux` and make it executable
2. Ensure `~/.local/bin` is in your PATH before `/opt/homebrew/bin` (or wherever real tmux lives)
3. Add the contents of `shell/fish.conf` or `shell/zsh.conf` to your shell config

## Usage

Open a new cmux tab and use Claude Code normally. When you create an agent team, teammates appear as split panes:

```
Tell Claude: "Create an agent team with 3 teammates"
```

Layout: leader on the left, teammates stacked vertically on the right.

To skip auto-launching claude in a new tab:
```bash
# fish
CMUX_NO_CLAUDE=1 fish

# zsh
CMUX_NO_CLAUDE=1 zsh
```

## Debug

Enable debug logging:
```bash
export CMUX_TMUX_SHIM_DEBUG=1
```

Logs go to `~/.local/state/cmux-tmux-shim/shim.log`.

## How it compares to the native cmux solution

There's an [open PR](https://github.com/manaflow-ai/cmux/pull/1102) to add this natively to cmux. When that ships, this shim becomes unnecessary. Key differences:

| | This shim | PR #1102 |
|-|-|-|
| Setup | Manual (install.sh) | Zero config (bundled) |
| Surface IDs | Works with UUIDs and refs | Refs only |
| list-panes | Only mapped panes (no tab leaks) | All panes |
| split-window -t | Respects target (relative split) | Ignores target |
| Session detection | Auto-resets stale state across sessions | Manual |
| Dependencies | Bash only | Requires python3 |
| Layout | Forced vertical stacking | Follows agent request |

## Uninstall

```bash
rm ~/.local/bin/tmux
rm -rf ~/.local/state/cmux-tmux-shim
```

Then remove the `cmux-tmux-shim` block from your shell config.

## License

MIT

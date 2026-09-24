# omarchy-monitor-arrange

Drag-and-drop monitor arrangement for [Omarchy](https://omarchy.org/) / Hyprland.

Detects your monitors with `hyprctl`, lets you drag them into position on a
canvas with edge snapping, and writes the result to `~/.config/hypr/monitors.lua`
in Omarchy's Lua config format.

A single self-contained Python script. No AUR packages, no extra dependencies
beyond what Omarchy already ships.

![Monitor Arrangement showing four screens on the canvas, with the selected
screen's resolution, scale and rotation in the side panel](docs/screenshot.png)

## Features

- **Drag to arrange** — screens snap to their neighbours' edges and centres
- **Per-monitor settings** — resolution, refresh rate, scale, rotation, enable/disable
- **Valid scales only** — the scale list offers only values that divide the mode
  into whole pixels, so Hyprland won't reject them
- **Apply before you commit** — test a layout live, then Save it or Revert
- **Safe by default** — refuses to save overlapping screens or to disable your
  last active display, and backs up `monitors.lua` before overwriting it
- Disabled screens park in a dashed row below the layout instead of piling up
  on the origin
- **Laptop panel knows about the dock** — switching off a built-in panel routes
  through Omarchy's internal-monitor toggle, so it stays off while docked and
  comes back on by itself when you undock

## Requirements

- Omarchy 4 / Hyprland with the Lua config (`~/.config/hypr/*.lua`)
- `python-gobject` and `gtk4` (both preinstalled on Omarchy)

## Install

```bash
./install.sh
```

Or by hand:

```bash
install -Dm755 omarchy-monitor-arrange ~/.local/bin/omarchy-monitor-arrange
install -Dm644 omarchy-monitor-arrange.desktop ~/.local/share/applications/
```

## Usage

```bash
omarchy-monitor-arrange
```

Or from the launcher as **Monitor Arrangement**.

Optional keybinding in `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + ALT + D", "Arrange monitors", { launch = "omarchy-monitor-arrange" })
```

`SUPER+CTRL+D` and `SUPER+SHIFT+D` are already taken by Omarchy defaults
(Display menu and Docker), hence `SUPER+ALT+D`.

| Button | What it does |
|---|---|
| **Detect** | Re-read the current monitor state from Hyprland |
| **Apply** | Apply the layout to the running session only — nothing written to disk |
| **Save** | Write `~/.config/hypr/monitors.lua` (with a timestamped backup) and reload |
| **Revert** | `hyprctl reload` — discard live changes and go back to what's on disk |

If a layout leaves you unable to see anything, **Revert** restores the saved
config. Nothing is written to disk until you press **Save**.

## Notes on Omarchy 4

Omarchy 4 uses Hyprland's Lua config parser, where `hyprctl keyword` is rejected:

```
keyword can't work with non-legacy parsers. Use eval.
```

So live changes are applied with `hyprctl eval` and a Lua `hl.monitor{...}` call
instead — the same form that gets written to `monitors.lua`:

```bash
hyprctl eval 'hl.monitor({ output = "DP-11", mode = "3440x1440@59.97", position = "5760x0", scale = 1 })'
```

The generated `monitors.lua` keeps Omarchy's `GDK_SCALE` line and the
`output = ""` fallback rule, so a newly plugged-in monitor still gets sensible
defaults instead of nothing.

### The built-in panel

A laptop panel is never written to `monitors.lua` as `disabled`. That would
outlive the dock, and undocking would leave you with no screen on at all.
Instead it is saved with the mode, scale and rotation it should come back on
with (`position = "auto"`), and switching it off is handed to
`omarchy-hyprland-monitor-internal`, the same toggle Omarchy's lid handler
uses — which clears itself once no external screen is active. That is what the
dashed **off while docked** tile means.

Settings for a disabled panel stay editable for the same reason: they describe
the state it returns to, not a screen that is gone.

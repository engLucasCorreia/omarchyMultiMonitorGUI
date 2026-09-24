#!/usr/bin/env bash
# Install omarchy-monitor-arrange for the current user.
set -euo pipefail
cd "$(dirname "$0")"

install -Dm755 omarchy-monitor-arrange "$HOME/.local/bin/omarchy-monitor-arrange"
install -Dm644 omarchy-monitor-arrange.desktop \
  "$HOME/.local/share/applications/omarchy-monitor-arrange.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "Installed. Run: omarchy-monitor-arrange"
echo
echo "Optional keybinding - add to ~/.config/hypr/bindings.lua:"
echo '  o.bind("SUPER + ALT + D", "Arrange monitors", { launch = "omarchy-monitor-arrange" })'

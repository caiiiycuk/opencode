#!/usr/bin/env bash
# Install or update opencode plugins: dcp, codegraph, ponytail, rtk.
set -euo pipefail

OPENCODE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

# --- dcp + ponytail (npm plugins managed by opencode) ---
# Bare `plugin update` skips a plugin whose cached copy fails to load (it can't
# "check" it), so each one is updated by name — that path always reinstalls.
for p in @tarquinen/opencode-dcp@latest @dietrichgebert/ponytail@latest; do
  opencode plugin add "$p"
  opencode plugin update "$p"
done

cat > "$OPENCODE_CONFIG/dcp.jsonc" <<'EOF'
{
  "$schema": "https://raw.githubusercontent.com/Opencode-DCP/opencode-dynamic-context-pruning/master/dcp.schema.json",
  "compress": {
    "minContextLimit": "50%",
    "maxContextLimit": "80%"
  }
}
EOF

# --- codegraph ---
# Same as rport/scripts: the upstream installer is also the upgrade path
# (versioned bundles under ~/.codegraph/versions, ~/.local/bin/codegraph repointed).
# Drop an npm-installed copy so it doesn't shadow the bundle on PATH.
npm uninstall -g @colbymchenry/codegraph >/dev/null 2>&1 || true
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
"$HOME/.local/bin/codegraph" install --target=opencode --location=global --yes
"$HOME/.local/bin/codegraph" telemetry off

# --- rtk ---
# Official installer puts the binary in ~/.local/bin. Drop a cargo-installed copy so it doesn't shadow the new one.
cargo uninstall rtk >/dev/null 2>&1 || true
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
rtk init -g --opencode --auto-patch

echo "done: $(opencode plugin list 2>/dev/null || true)"
echo "codegraph $(codegraph --version), rtk $(rtk --version)"

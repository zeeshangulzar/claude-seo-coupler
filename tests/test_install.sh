#!/usr/bin/env bash
# Installs and uninstalls into a throwaway HOME and checks the results.
# Never touches the real ~/.claude or ~/.claude.json.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "${TMP_HOME}"' EXIT
export HOME="${TMP_HOME}"

fail() { echo "FAIL: $*"; exit 1; }

# An existing config with another server and other keys must survive.
cat > "${HOME}/.claude.json" <<'JSON'
{"theme": "dark", "mcpServers": {"other": {"type": "http", "url": "https://example.com/mcp"}}}
JSON

"${REPO}/install.sh" >/dev/null

cmp -s "${REPO}/skills/seo-coupler/SKILL.md" "${HOME}/.claude/skills/seo-coupler/SKILL.md" \
    || fail "skill not copied"
python3 - "${HOME}/.claude.json" <<'PY' || fail "install config"
import json, sys
d = json.load(open(sys.argv[1]))
assert d["mcpServers"]["coupler-io"] == {"type": "http", "url": "https://mcp.coupler.io/mcp"}
assert d["mcpServers"]["other"]["url"] == "https://example.com/mcp"
assert d["theme"] == "dark"
PY
[ "$(stat -c %a "${HOME}/.claude.json" 2>/dev/null || stat -f %Lp "${HOME}/.claude.json")" = "600" ] \
    || fail "config mode is not 600"

# Re-running is safe.
"${REPO}/install.sh" >/dev/null

"${REPO}/uninstall.sh" >/dev/null

[ ! -e "${HOME}/.claude/skills/seo-coupler" ] || fail "skill not removed"
python3 - "${HOME}/.claude.json" <<'PY' || fail "uninstall config"
import json, sys
d = json.load(open(sys.argv[1]))
assert "coupler-io" not in d["mcpServers"]
assert d["mcpServers"]["other"]["url"] == "https://example.com/mcp"
assert d["theme"] == "dark"
PY

# Uninstalling twice is safe.
"${REPO}/uninstall.sh" >/dev/null

# A broken config is left alone.
echo '{broken' > "${HOME}/.claude.json"
if "${REPO}/install.sh" >/dev/null 2>&1; then fail "install accepted invalid JSON"; fi
[ "$(cat "${HOME}/.claude.json")" = "{broken" ] || fail "invalid config was modified"

echo "PASS"

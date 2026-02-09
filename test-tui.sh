#!/bin/bash
# Quick smoke tests for openclaw-tools
# Run: ./test-tui.sh

set -euo pipefail

TOOL="$(cd "$(dirname "$0")" && pwd)/openclaw-tools"
PASS=0
FAIL=0

pass() { echo "  ✓ $1"; ((PASS++)) || true; }
fail() { echo "  ✗ $1"; ((FAIL++)) || true; }

echo "Testing: $TOOL"
echo ""

# ── 1. Script exists and is executable ────────────────────────────────────
echo "Basics:"
if [[ -x "$TOOL" ]]; then pass "Script is executable"
else fail "Script is not executable"; fi

# ── 2. Bash syntax check ─────────────────────────────────────────────────
if bash -n "$TOOL" 2>/dev/null; then pass "Syntax check passes"
else fail "Syntax errors found"; fi

# ── 3. Platform detection ────────────────────────────────────────────────
echo ""
echo "Platform detection:"
platform="$(uname -s)"
if [[ "$platform" == "Darwin" ]] || [[ "$platform" == "Linux" ]]; then
    pass "Running on supported platform: $platform"
else
    fail "Unsupported platform: $platform"
fi

# ── 4. Source the platform block only (no TUI) ───────────────────────────
eval "$(sed -n '/^# ── Platform detection/,/^esac$/p' "$TOOL")"
if [[ -n "${PLATFORM_NAME:-}" ]]; then pass "PLATFORM_NAME set: $PLATFORM_NAME"
else fail "PLATFORM_NAME not set"; fi

if [[ -n "${PLATFORM_SHORT:-}" ]]; then pass "PLATFORM_SHORT set: $PLATFORM_SHORT"
else fail "PLATFORM_SHORT not set"; fi

if [[ -n "${NODE_INSTALL_HINT:-}" ]]; then pass "NODE_INSTALL_HINT set"
else fail "NODE_INSTALL_HINT not set"; fi

if [[ -n "${SHARED_PATH:-}" ]]; then pass "SHARED_PATH set: $SHARED_PATH"
else fail "SHARED_PATH not set"; fi

if [[ -n "${DAEMON_TYPE:-}" ]]; then pass "DAEMON_TYPE set: $DAEMON_TYPE"
else fail "DAEMON_TYPE not set"; fi

# ── 5. Wrapper functions exist ───────────────────────────────────────────
echo ""
echo "Wrapper functions defined:"
for fn in port_is_listening port_listener_owner port_listener_pid \
          port_listener_pids port_listener_is_node daemon_install \
          daemon_start daemon_uninstall sed_inplace stat_permissions \
          get_desktop_path; do
    if grep -q "^${fn}()" "$TOOL"; then pass "$fn()"
    else fail "$fn() missing"; fi
done

# ── 6. No raw platform commands outside wrappers ─────────────────────────
echo ""
echo "No leaking platform-specific code:"

wrapper_end=$(grep -n "^# ── Output helpers\|^# ── Colors\|^BOX_W=" "$TOOL" | head -1 | cut -d: -f1)
if [[ -z "$wrapper_end" ]]; then
    wrapper_end=$(grep -n "^info()" "$TOOL" | head -1 | cut -d: -f1)
fi

if [[ -n "$wrapper_end" ]]; then
    if tail -n +"$wrapper_end" "$TOOL" | grep -q 'lsof -i'; then
        fail "Raw 'lsof -i' found outside wrappers"
    else
        pass "No raw lsof outside wrappers"
    fi

    if tail -n +"$wrapper_end" "$TOOL" | grep -q 'launchctl'; then
        fail "Raw 'launchctl' found outside wrappers"
    else
        pass "No raw launchctl outside wrappers"
    fi

    if tail -n +"$wrapper_end" "$TOOL" | grep -q "sed -i"; then
        fail "Raw 'sed -i' found outside wrappers"
    else
        pass "No raw sed -i outside wrappers"
    fi
else
    fail "Could not determine wrapper section boundary"
fi

# ── 7. Gum dependency ───────────────────────────────────────────────────
echo ""
echo "Gum integration:"
if grep -q "command -v gum" "$TOOL"; then pass "Checks for gum at startup"
else fail "No gum check found"; fi

if grep -q "gum choose" "$TOOL"; then pass "Uses gum choose for menus"
else fail "No gum choose calls found"; fi

if grep -q "gum confirm" "$TOOL"; then pass "Uses gum confirm for yes/no"
else fail "No gum confirm calls found"; fi

if grep -q "gum input" "$TOOL"; then pass "Uses gum input for text entry"
else fail "No gum input calls found"; fi

if grep -q "gum style" "$TOOL"; then pass "Uses gum style for formatting"
else fail "No gum style calls found"; fi

if grep -q -- "--no-limit" "$TOOL"; then pass "Uses gum choose --no-limit for multi-select"
else fail "No multi-select found"; fi

# ── 8. No broken TUI code remains ───────────────────────────────────────
echo ""
echo "Old TUI code removed:"
if grep -q "menu_select\|checkbox_select\|MENU_RESULT\|CHECKBOX_INDICES" "$TOOL"; then
    fail "Old custom TUI functions still present"
else
    pass "No custom menu_select/checkbox_select code"
fi

if grep -q "box_top\|box_bottom\|box_mid\|box_line\|box_empty\|BOX_W=" "$TOOL"; then
    fail "Old box-drawing code still present"
else
    pass "No custom box-drawing code"
fi

if grep -q "read -rsn1\|\\\\033\[?25l\|\\\\033\[2J" "$TOOL"; then
    fail "Old raw terminal escape codes still present"
else
    pass "No raw terminal escape codes"
fi

# ── 9. Feature functions exist ───────────────────────────────────────────
echo ""
echo "Feature functions defined:"
for fn in setup_fresh_default setup_new_profile setup_reconfigure \
          setup_different_user interactive_copy_menu pick_port \
          run_status run_backup run_migrate run_nuke; do
    if grep -q "^${fn}()" "$TOOL"; then pass "$fn()"
    else fail "$fn() missing"; fi
done

# ── 10. install.sh syntax and gum install ────────────────────────────────
echo ""
echo "install.sh:"
INSTALLER="$(cd "$(dirname "$0")" && pwd)/install.sh"
if [[ -f "$INSTALLER" ]]; then
    if bash -n "$INSTALLER" 2>/dev/null; then pass "install.sh syntax OK"
    else fail "install.sh has syntax errors"; fi

    if grep -q "install_gum" "$INSTALLER"; then pass "install.sh installs gum"
    else fail "install.sh doesn't install gum"; fi

    if grep -q "brew install gum" "$INSTALLER"; then pass "install.sh supports macOS (brew)"
    else fail "install.sh missing brew gum install"; fi

    if grep -q "charm.sh" "$INSTALLER"; then pass "install.sh supports Linux (charm repo)"
    else fail "install.sh missing Linux gum install"; fi
else
    fail "install.sh not found"
fi

# ── Summary ──────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[[ $FAIL -eq 0 ]] && exit 0 || exit 1

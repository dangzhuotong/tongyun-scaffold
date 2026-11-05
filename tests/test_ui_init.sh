#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export SKIP_SKILLS_SYNC=1
for theme in paper paper-dark desktop cloud; do
  bash "$ROOT/scripts/init-project.sh" --ui "$theme" demo desc "$WORK/$theme" >/dev/null
  test -f "$WORK/$theme/ui/adapters/react.tsx"
  test -f "$WORK/$theme/ui/tokens/tokens.css"
  grep -q "$theme" "$WORK/$theme/DESIGN.md"
done
printf 'custom design\n' > "$WORK/paper/DESIGN.md"
printf 'custom css\n' > "$WORK/paper/ui/components/ui.css"
rm "$WORK/paper/ui/adapters/react.tsx"
bash "$ROOT/scripts/init-project.sh" --ui cloud demo desc "$WORK/paper" >/dev/null
test ! -e "$WORK/paper/ui/adapters/react.tsx"
test "$(cat "$WORK/paper/DESIGN.md")" = 'custom design'
test "$(cat "$WORK/paper/ui/components/ui.css")" = 'custom css'
FORCE=1 bash "$ROOT/scripts/init-project.sh" --ui cloud demo desc "$WORK/paper" >/dev/null
test -f "$WORK/paper/ui/adapters/react.tsx"
cmp "$ROOT/design-system/components/ui.css" "$WORK/paper/ui/components/ui.css"
grep -q cloud "$WORK/paper/DESIGN.md"
bash "$ROOT/scripts/init-project.sh" demo desc "$WORK/none" >/dev/null
test ! -e "$WORK/none/ui"
test ! -e "$WORK/none/DESIGN.md"
if bash "$ROOT/scripts/init-project.sh" --ui invalid x y "$WORK/invalid" >/dev/null 2>&1; then exit 1; fi
test ! -e "$WORK/invalid"
node "$ROOT/design-system/scripts/build-tokens.mjs" --check
node "$ROOT/design-system/tests/contracts.mjs"
echo 'ui init ok'

#!/usr/bin/env bash
set -euo pipefail
NAME="${1:-my-project}"
PURPOSE="${2:-（待填写项目用途）}"
TARGET="${3:-.}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/templates"
[[ -d "$TPL" ]] || { echo "请在 clone 的 tongyun-scaffold 里执行（需要 templates/）" >&2; exit 1; }
mkdir -p "$TARGET/docs/decisions" "$TARGET/docs/testing" "$TARGET/docs/design"
render() { sed -e "s/{{PROJECT_NAME}}/${NAME//\//\\/}/g" -e "s/{{PROJECT_PURPOSE}}/${PURPOSE//\//\\/}/g" "$1" > "$2"; }
render "$TPL/AGENTS.md" "$TARGET/AGENTS.md"
render "$TPL/docs/prd.md" "$TARGET/docs/prd.md"
cp "$TPL/docs/plan.md" "$TARGET/docs/plan.md"
cp "$TPL/docs/architecture.md" "$TARGET/docs/architecture.md"
cp "$TPL/docs/development.md" "$TARGET/docs/development.md"
cp "$TPL/docs/user-flows.md" "$TARGET/docs/user-flows.md"
cp "$TPL/docs/skills.md" "$TARGET/docs/skills.md"
cp "$TPL/docs/testing/acceptance-tests.md" "$TARGET/docs/testing/acceptance-tests.md"
cp "$TPL/docs/decisions/"* "$TARGET/docs/decisions/"
if [[ ! -f "$TARGET/.gitignore" ]]; then
  printf '%s\n' .DS_Store .env '.env.*' '!.env.example' 'secrets*' '*.pem' node_modules/ target/ dist/ build/ .venv/ > "$TARGET/.gitignore"
fi
mkdir -p "$TARGET/scripts"
cp "$ROOT/scripts/install-coding-skills.sh" "$TARGET/scripts/"
chmod +x "$TARGET/scripts/install-coding-skills.sh"
echo "已写入 $TARGET ：AGENTS.md docs/ .gitignore"

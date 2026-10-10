#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-my-project}"
PURPOSE="${2:-（待填写项目用途）}"
TARGET="${3:-.}"
TARGET="${TARGET%/}"
[[ -z "$TARGET" ]] && TARGET="/"
FORCE="${FORCE:-0}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/templates"
[[ -d "$TPL" ]] || { echo "请在 clone 的 tongyun-scaffold 里执行（需要 templates/）" >&2; exit 1; }

mkdir -p "$TARGET/docs/decisions" "$TARGET/docs/testing" "$TARGET/docs/design" "$TARGET/scripts"

# 用 sed 自己转义，避免不同 bash 版本对 ${var//&/...} 的处理差异（macOS bash 3.2 / bash 5.2 patsub_replacement）
escape_sed() {
  printf '%s' "$1" | sed -e 's/[\\/&]/\\&/g'
}

ESC_NAME="$(escape_sed "$NAME")"
ESC_PURPOSE="$(escape_sed "$PURPOSE")"

render_file() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" && "$FORCE" != "1" ]]; then
    echo "跳过 $dst（已存在）"
    return 0
  fi
  sed -e "s/{{PROJECT_NAME}}/$ESC_NAME/g" -e "s/{{PROJECT_PURPOSE}}/$ESC_PURPOSE/g" "$src" > "$dst"
}

copy_file() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" && "$FORCE" != "1" ]]; then
    echo "跳过 $dst（已存在）"
    return 0
  fi
  cp "$src" "$dst"
}

render_file "$TPL/AGENTS.md" "$TARGET/AGENTS.md"
render_file "$TPL/docs/prd.md" "$TARGET/docs/prd.md"
copy_file "$TPL/docs/plan.md" "$TARGET/docs/plan.md"
copy_file "$TPL/docs/architecture.md" "$TARGET/docs/architecture.md"
copy_file "$TPL/docs/development.md" "$TARGET/docs/development.md"
copy_file "$TPL/docs/user-flows.md" "$TARGET/docs/user-flows.md"
copy_file "$TPL/docs/skills.md" "$TARGET/docs/skills.md"
copy_file "$TPL/docs/testing/acceptance-tests.md" "$TARGET/docs/testing/acceptance-tests.md"
copy_file "$TPL/docs/design/README.md" "$TARGET/docs/design/README.md"

for file in "$TPL/docs/decisions/"*; do
  [[ -f "$file" ]] || continue
  copy_file "$file" "$TARGET/docs/decisions/$(basename "$file")"
done

if [[ ! -f "$TARGET/.gitignore" ]]; then
  printf '%s\n' .DS_Store .env '.env.*' '!.env.example' 'secrets*' '*.pem' node_modules/ target/ dist/ build/ .venv/ .cursor/skills/ .agents/skills/ > "$TARGET/.gitignore"
else
  for pattern in ".cursor/skills/" ".agents/skills/"; do
    if ! grep -qxF "$pattern" "$TARGET/.gitignore" 2>/dev/null; then
      if [[ -s "$TARGET/.gitignore" ]] && [ -n "$(tail -c 1 "$TARGET/.gitignore" 2>/dev/null)" ]; then
        echo "" >> "$TARGET/.gitignore"
      fi
      echo "$pattern" >> "$TARGET/.gitignore"
    fi
  done
fi

copy_file "$ROOT/scripts/install-coding-skills.sh" "$TARGET/scripts/install-coding-skills.sh"
chmod +x "$TARGET/scripts/install-coding-skills.sh"

echo "已写入 $TARGET ：AGENTS.md docs/ .gitignore"

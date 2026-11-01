#!/usr/bin/env bash
# 初始化 Tongyun 系列新项目：AGENTS/CLAUDE、docs 骨架、.agents/{skills,notes}，并复制 Coding 套装 skill（tongyun 系列）。
# 用法：bash scripts/init-project.sh [--edition tongyun|pro] <项目名> <一句话用途> [目标目录，默认 .]
#   --edition pro 为兼容别名；lite 已停用，现行技能使用来源仓商业许可。
# 环境变量：FORCE=1 覆盖已存在文件；SKIP_SKILLS_SYNC=1 不同步 skill；TONGYUN_SKILLS_EDITION=tongyun|pro 同 --edition；
#           skill 来源变量见 scripts/sync-skills.sh
set -euo pipefail

EDITION="${TONGYUN_SKILLS_EDITION:-tongyun}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --edition) [[ $# -ge 2 && -n "$2" ]] || { echo "--edition 需要 tongyun 或 pro" >&2; exit 2; }; EDITION="$2"; shift 2 ;;
    --edition=*) [[ -n "${1#--edition=}" ]] || { echo "--edition 需要 tongyun 或 pro" >&2; exit 2; }; EDITION="${1#--edition=}"; shift ;;
    -*) echo "未知参数 $1" >&2; exit 2 ;;
    *) break ;;
  esac
done
case "$EDITION" in
  tongyun|pro) ;;
  lite) echo "lite 已停用；现行 tongyun-skills 为商业技能库，请确认许可后使用 --edition tongyun。" >&2; exit 2 ;;
  *) echo "版本只能是 tongyun 或 pro，收到：$EDITION" >&2; exit 2 ;;
esac

NAME="${1:-my-project}"
PURPOSE="${2:-（待填写项目用途）}"
TARGET="${3:-.}"
TARGET="${TARGET%/}"
[[ -z "$TARGET" ]] && TARGET="/"
FORCE="${FORCE:-0}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/templates"
[[ -d "$TPL" ]] || { echo "请在 clone 的 tongyun-scaffold 里执行（需要 templates/）" >&2; exit 1; }

mkdir -p "$TARGET"
if [[ "$(cd "$TARGET" && pwd)" == "$ROOT" ]]; then
  echo "不要初始化到脚手架仓自身（公开仓不能带 skill 正文）。用法：bash $ROOT/scripts/init-project.sh <名> <用途> <新项目目录>" >&2
  exit 1
fi

mkdir -p "$TARGET/docs/decisions" "$TARGET/docs/testing" "$TARGET/docs/design" "$TARGET/scripts" "$TARGET/.agents/skills"
for state in proposed implemented rejected archived; do
  mkdir -p "$TARGET/.agents/notes/$state"
  [[ -e "$TARGET/.agents/notes/$state/.gitkeep" ]] || : > "$TARGET/.agents/notes/$state/.gitkeep"
done

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
    echo "跳过 ${dst}（已存在）"
    return 0
  fi
  sed -e "s/{{PROJECT_NAME}}/$ESC_NAME/g" -e "s/{{PROJECT_PURPOSE}}/$ESC_PURPOSE/g" "$src" > "$dst"
}

copy_file() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" && "$FORCE" != "1" ]]; then
    echo "跳过 ${dst}（已存在）"
    return 0
  fi
  cp "$src" "$dst"
}

# 软链：已是软链则刷新；是真实文件/目录则不动并提示
make_link() {
  local link_target="$1"
  local path="$2"
  mkdir -p "$(dirname "$path")"
  if [[ -L "$path" || ! -e "$path" ]]; then
    ln -sfn "$link_target" "$path"
  else
    echo "跳过 ${path}（已存在且不是软链，请手动处理）"
  fi
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
copy_file "$TPL/docs/design/ui-guard.md" "$TARGET/docs/design/ui-guard.md"
copy_file "$TPL/.agents/notes/README.md" "$TARGET/.agents/notes/README.md"

for file in "$TPL/docs/decisions/"*; do
  [[ -f "$file" ]] || continue
  copy_file "$file" "$TARGET/docs/decisions/$(basename "$file")"
done

# CLAUDE.md 与 AGENTS.md 同一份（同 deepseek-harness：软链）
make_link AGENTS.md "$TARGET/CLAUDE.md"
# Claude Code / Cursor 读各自目录，统一指向 .agents/skills
make_link ../.agents/skills "$TARGET/.claude/skills"
make_link ../.agents/skills "$TARGET/.cursor/skills"

# .gitignore：skill 是项目文件，要提交——不能忽略 .agents/skills 及其入口
if [[ ! -f "$TARGET/.gitignore" ]]; then
  printf '%s\n' .DS_Store .env '.env.*' '!.env.example' 'secrets*' '*.pem' node_modules/ target/ dist/ build/ .venv/ > "$TARGET/.gitignore"
else
  if grep -qxE '\.(agents|cursor|claude)/skills/?' "$TARGET/.gitignore"; then
    tmp_gi="$(mktemp)"
    grep -vxE '\.(agents|cursor|claude)/skills/?' "$TARGET/.gitignore" > "$tmp_gi" || true
    cat "$tmp_gi" > "$TARGET/.gitignore"
    rm -f "$tmp_gi"
    echo "已从 .gitignore 移除 skills 忽略规则（skill 现在随项目提交）"
  fi
fi

copy_file "$ROOT/scripts/sync-skills.sh" "$TARGET/scripts/sync-skills.sh"
chmod +x "$TARGET/scripts/sync-skills.sh"

echo "已写入 $TARGET ：AGENTS.md CLAUDE.md docs/ .agents/ .gitignore"

if [[ "${SKIP_SKILLS_SYNC:-0}" == "1" ]]; then
  echo "已跳过 skill 同步（SKIP_SKILLS_SYNC=1）。之后在项目根目录运行：bash scripts/sync-skills.sh"
elif ! bash "$TARGET/scripts/sync-skills.sh" --edition "$EDITION" "$TARGET"; then
  cat >&2 <<'MSG'

⚠️  警告：未取得完整 tongyun-skills Coding 套装，技能未复制（项目其余部分已初始化成功）。
   核对来源仓权限与商业许可后，在项目根目录运行：
     bash scripts/sync-skills.sh
   或指定已有本地 checkout：
     TONGYUN_SKILLS=/path/to/tongyun-skills bash scripts/sync-skills.sh
MSG
fi

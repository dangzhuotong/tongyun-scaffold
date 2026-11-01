#!/usr/bin/env bash
# 同步现行 tongyun-skills Coding 套装到项目；不写全局技能目录。
# 用法：bash scripts/sync-skills.sh [--edition tongyun|pro] [项目根目录]
# 来源：TONGYUN_SKILLS（本地 checkout）→ TONGYUN_SKILLS_CACHE → clone。
# TONGYUN_SKILLS_GIT 默认 https://github.com/dangzhuotong/tongyun-skills.git。
# 旧 TONGYUN_SKILLS_PLUS / TONGYUN_SKILLS_PLUS_GIT 和 --edition pro 兼容。
# lite 已停用；不会把商业技能伪装成 MIT lite。
# 退出码：0 成功；1 来源不可用（目标未改）；2 参数/目标错误。
set -euo pipefail

BASES="product ui-design api test code-review deploy mac-ship"
LEGACY_BASES="project product ui-design api test code-review deploy"
SKILLS=""
for b in $BASES; do SKILLS="$SKILLS tongyun-$b"; done
usage() { echo "用法：bash scripts/sync-skills.sh [--edition tongyun|pro] [项目根目录]" >&2; }
EDITION_ARG=""
PROJECT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --edition) [[ $# -ge 2 && -n "$2" ]] || { usage; exit 2; }; EDITION_ARG="$2"; shift 2 ;;
    --edition=*) [[ -n "${1#--edition=}" ]] || { usage; exit 2; }; EDITION_ARG="${1#--edition=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "sync-skills: 未知参数 $1" >&2; usage; exit 2 ;;
    *) [[ -z "$PROJECT" ]] || { usage; exit 2; }; PROJECT="$1"; shift ;;
  esac
done
case "${EDITION_ARG:-${TONGYUN_SKILLS_EDITION:-tongyun}}" in
  tongyun|pro) ;;
  lite) echo "sync-skills: lite 已停用；现行 tongyun-skills 为商业技能库，请确认许可后使用 --edition tongyun。" >&2; exit 2 ;;
  *) echo "sync-skills: 版本只能是 tongyun 或 pro（兼容别名）" >&2; exit 2 ;;
esac
EDITION="tongyun"
PROJECT="${PROJECT:-$(cd "$(dirname "$0")/.." && pwd)}"
[[ -d "$PROJECT" ]] || { echo "sync-skills: 项目目录不存在：$PROJECT" >&2; exit 2; }
PROJECT="$(cd "$PROJECT" && pwd)"
if [[ -f "$PROJECT/scripts/init-project.sh" && -d "$PROJECT/templates" ]]; then
  echo "sync-skills: $PROJECT 看起来是 tongyun-scaffold 本身（公开仓），拒绝写入 skill 正文。" >&2
  exit 2
fi
DEST="$PROJECT/.agents/skills"
warn() { echo "sync-skills: $*" >&2; }
LOCAL_SRC="${TONGYUN_SKILLS:-${TONGYUN_SKILLS_PLUS:-}}"
LOCAL_VAR="TONGYUN_SKILLS / TONGYUN_SKILLS_PLUS"
REPO_URL="${TONGYUN_SKILLS_GIT:-${TONGYUN_SKILLS_PLUS_GIT:-https://github.com/dangzhuotong/tongyun-skills.git}}"
CACHE="${TONGYUN_SKILLS_CACHE:-$HOME/.cache/tongyun-skills}"
LABEL="tongyun-skills（商业许可，需来源仓访问权限）"

SRC=""
if [[ -n "$LOCAL_SRC" ]]; then
  if [[ -d "$LOCAL_SRC/skills" ]]; then
    SRC="$LOCAL_SRC"
  else
    warn "${LOCAL_VAR}=$LOCAL_SRC 下没有 skills/ 目录"
    exit 1
  fi
elif [[ -d "$CACHE/skills" ]]; then
  SRC="$CACHE"
  if [[ -d "$CACHE/.git" ]]; then
    git -C "$CACHE" pull --ff-only --quiet || warn "缓存 git pull 失败，沿用本地缓存版本（${CACHE}）"
  fi
else
  if [[ -e "$CACHE" ]]; then
    warn "缓存路径 $CACHE 已存在但不是 skill 仓 checkout，请删掉后重试"
    exit 1
  fi
  mkdir -p "$(dirname "$CACHE")"
  echo "sync-skills: clone $LABEL …"
  if ! git clone --quiet "$REPO_URL" "$CACHE"; then
    rm -rf "$CACHE"
    warn "clone 失败：$REPO_URL"
    exit 1
  fi
  SRC="$CACHE"
fi

for name in $SKILLS; do
  if [[ ! -f "$SRC/skills/$name/SKILL.md" ]]; then
    warn "源里缺 $SRC/skills/$name/SKILL.md（Tongyun Coding 套装）"
    exit 1
  fi
done

if [[ ! -f "$SRC/skills/tongyun-product/jobs/project/JOB.md" ]]; then
  warn "源里缺 tongyun-product/jobs/project/JOB.md"
  exit 1
fi

# 来源信息（去掉 URL 里的账号/令牌）
SRC_URL="(非 git checkout)"
HAVE_GIT=0
if git -C "$SRC" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  HAVE_GIT=1
  SRC_URL="$(git -C "$SRC" remote get-url origin 2>/dev/null || echo '(无 origin)')"
  SRC_URL="$(printf '%s' "$SRC_URL" | sed -E 's#(https?://)[^@/]*@#\1#')"
fi

mkdir -p "$DEST"
STAGE="$(mktemp -d "$DEST/.sync.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT

ROWS=""
for name in $SKILLS; do
  # -L：源里若有软链，复制成真实文件，保证 clone 到别的机器也能用
  cp -RL "$SRC/skills/$name" "$STAGE/$name"
  # 排除测试与临时文件
  find "$STAGE/$name" \( -name tests -o -name test -o -name __pycache__ -o -name .pytest_cache -o -name tmp -o -name node_modules \) -type d -prune -exec rm -rf {} +
  find "$STAGE/$name" -type f \( -name '*.pyc' -o -name '*.tmp' -o -name '*.log' -o -name '*.swp' -o -name '.DS_Store' -o -name 'Thumbs.db' -o -name '*~' \) -delete
  sha="unknown"
  if [[ "$HAVE_GIT" == 1 ]]; then
    sha="$(git -C "$SRC" log -1 --format=%H -- "skills/$name" 2>/dev/null || true)"
    [[ -n "$sha" ]] || sha="unknown"
    if [[ -n "$(git -C "$SRC" status --porcelain -- "skills/$name" 2>/dev/null)" ]]; then
      sha="$sha+dirty"
    fi
  fi
  ROWS="$ROWS| \`$name\` | \`skills/$name\` | \`$sha\` |
"
done

HEAD_SHA="unknown"
[[ "$HAVE_GIT" == 1 ]] && HEAD_SHA="$(git -C "$SRC" rev-parse HEAD)"

# 先完成新套装复制，再清理精确匹配的旧工种目录；保留项目自定义技能。
for name in $SKILLS; do
  rm -rf "${DEST:?}/$name"
  mv "$STAGE/$name" "$DEST/$name"
done
for b in $LEGACY_BASES; do
  rm -rf "${DEST:?}/tong-$b" "${DEST:?}/tong-$b-pro"
done

cat > "$DEST/SOURCES.md" <<MD
# 项目 skill 来源

本文件由 \`scripts/sync-skills.sh\` 生成，不要手改。

- edition: $EDITION
- 来源仓：$SRC_URL
- 来源 HEAD：\`$HEAD_SHA\`
- 同步时间：$(date -u +%Y-%m-%dT%H:%M:%SZ)

| skill | 源路径 | 最后改动该目录的 commit |
| --- | --- | --- |
${ROWS}
仅表中七个 \`tongyun-*\` 目录由本脚本刷新，项目自定义技能不受影响。
项目规范位于 \`tongyun-product/jobs/project/JOB.md\`，不再单独安装 project 工种。

注意：tongyun-skills 为商业技能库，使用与分发遵循来源许可。项目公开前核对授权；脚手架本身的 MIT 许可不适用于复制进项目的技能。
MD

# 精确迁移 Markdown skill 链接，不改相似名称或任意正文。
# project 已并入 product/jobs/project，不能简单添加 tongyun- 前缀。
AGENTS_FILE="$PROJECT/AGENTS.md"
if [[ -f "$AGENTS_FILE" && ! -L "$AGENTS_FILE" ]]; then
  sed_script="$STAGE/migrate.sed"
  tmp_agents="$STAGE/AGENTS.md"
  for b in $LEGACY_BASES; do
    new="tongyun-$b/SKILL.md"
    [[ "$b" == project ]] && new="tongyun-product/jobs/project/JOB.md"
    for old in "tong-$b" "tong-$b-pro"; do
      label="tongyun-$b"
      [[ "$b" == project ]] && label="tongyun-product/jobs/project"
      printf 's#\\[%s\\](\\.agents/skills/%s/SKILL\\.md)#[%s](.agents/skills/%s)#g\n' "$old" "$old" "$label" "$new" >> "$sed_script"
      printf 's#](\\.agents/skills/%s/SKILL\\.md)#](.agents/skills/%s)#g\n' "$old" "$new" >> "$sed_script"
    done
  done
  sed -f "$sed_script" "$AGENTS_FILE" > "$tmp_agents"
  if ! cmp -s "$tmp_agents" "$AGENTS_FILE"; then
    cat "$tmp_agents" > "$AGENTS_FILE"
    echo "sync-skills: 已迁移 AGENTS.md 到 tongyun 系列链接"
  fi
fi

# Claude Code / Cursor 复用同一份；保护已有真实目录。
for link in .claude/skills .cursor/skills; do
  p="$PROJECT/$link"
  if [[ -L "$p" || ! -e "$p" ]]; then
    mkdir -p "$(dirname "$p")"
    ln -sfn ../.agents/skills "$p"
  else
    warn "$link 是真实目录，未改成软链；请按需手动迁移"
  fi
done
echo "sync-skills: 已同步 7 个 Tongyun Coding skill 到 ${DEST}（源 $SRC_URL @ ${HEAD_SHA:0:7}）"

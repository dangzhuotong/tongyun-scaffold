#!/usr/bin/env bash
# 把 tongyun-skills-plus 的 Coding 套装（7 个 tong-*-pro）以「真实文件」复制进本项目 .agents/skills/。
# - 项目级：随项目一起提交；只写 <项目>/.agents/skills，绝不写 ~/.cursor ~/.codex ~/.workbuddy 等全局目录。
# - 重复运行 = 原地刷新到 skills-plus 最新；tong-* 目录由本脚本管理，本地改动会被覆盖。
#   项目自己的 skill 请用 <项目名>-xxx 命名放在同一目录，本脚本不会碰。
# 用法：bash scripts/sync-skills.sh [项目根目录，默认=本脚本上一级]
# 环境变量：
#   TONGYUN_SKILLS_PLUS       已有 skills-plus 本地路径（设置了就只用它）
#   TONGYUN_SKILLS_CACHE      缓存路径，默认 ~/.cache/tongyun-skills-plus
#   TONGYUN_SKILLS_PLUS_GIT   clone 地址，默认 git@github.com:dangzhuotong/tongyun-skills-plus.git
# 退出码：0 成功；1 拿不到 skills-plus 或源缺 skill（项目文件未改动）；2 参数/目标错误。
set -euo pipefail

SKILLS="tong-project-pro tong-product-pro tong-ui-design-pro tong-api-pro tong-test-pro tong-code-review-pro tong-deploy-pro"

PROJECT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
[[ -d "$PROJECT" ]] || { echo "sync-skills: 项目目录不存在：$PROJECT" >&2; exit 2; }
PROJECT="$(cd "$PROJECT" && pwd)"

# 公开脚手架仓本身不能装 skill 正文（skills-plus 私有、商业许可）
if [[ -f "$PROJECT/scripts/init-project.sh" && -d "$PROJECT/templates" ]]; then
  echo "sync-skills: $PROJECT 看起来是 tongyun-scaffold 本身（公开仓），拒绝写入 skill 正文。请对 init 出来的项目运行。" >&2
  exit 2
fi

REPO_URL="${TONGYUN_SKILLS_PLUS_GIT:-git@github.com:dangzhuotong/tongyun-skills-plus.git}"
CACHE="${TONGYUN_SKILLS_CACHE:-$HOME/.cache/tongyun-skills-plus}"

warn() { echo "sync-skills: $*" >&2; }

SRC=""
if [[ -n "${TONGYUN_SKILLS_PLUS:-}" ]]; then
  if [[ -d "$TONGYUN_SKILLS_PLUS/skills" ]]; then
    SRC="$TONGYUN_SKILLS_PLUS"
  else
    warn "TONGYUN_SKILLS_PLUS=$TONGYUN_SKILLS_PLUS 下没有 skills/ 目录"
    exit 1
  fi
elif [[ -d "$CACHE/skills" ]]; then
  SRC="$CACHE"
  if [[ -d "$CACHE/.git" ]]; then
    git -C "$CACHE" pull --ff-only --quiet || warn "缓存 git pull 失败，沿用本地缓存版本（${CACHE}）"
  fi
else
  if [[ -e "$CACHE" ]]; then
    warn "缓存路径 $CACHE 已存在但不是 skills-plus checkout，请删掉后重试"
    exit 1
  fi
  mkdir -p "$(dirname "$CACHE")"
  echo "sync-skills: clone skills-plus（私有仓，需本机 SSH 能访问 GitHub）…"
  if ! git clone --quiet "$REPO_URL" "$CACHE"; then
    rm -rf "$CACHE"
    warn "clone 失败：$REPO_URL"
    exit 1
  fi
  SRC="$CACHE"
fi

for name in $SKILLS; do
  if [[ ! -f "$SRC/skills/$name/SKILL.md" ]]; then
    warn "源里缺 $SRC/skills/$name/SKILL.md"
    exit 1
  fi
done

# 来源信息（去掉 URL 里的账号/令牌）
SRC_URL="(非 git checkout)"
HAVE_GIT=0
if git -C "$SRC" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  HAVE_GIT=1
  SRC_URL="$(git -C "$SRC" remote get-url origin 2>/dev/null || echo '(无 origin)')"
  SRC_URL="$(printf '%s' "$SRC_URL" | sed -E 's#(https?://)[^@/]*@#\1#')"
fi

DEST="$PROJECT/.agents/skills"
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

# 原地替换
for name in $SKILLS; do
  rm -rf "${DEST:?}/$name"
  mv "$STAGE/$name" "$DEST/$name"
done

cat > "$DEST/SOURCES.md" <<MD
# 项目 skill 来源

本文件由 \`scripts/sync-skills.sh\` 生成，不要手改。

- 来源仓：$SRC_URL
- 来源 HEAD：\`$HEAD_SHA\`
- 同步时间：$(date -u +%Y-%m-%dT%H:%M:%SZ)

| skill | 源路径 | 最后改动该目录的 commit |
| --- | --- | --- |
${ROWS}
\`tong-*\` 目录由同步脚本管理，重跑会覆盖本地改动；项目自己的 skill 用 \`<项目名>-xxx\` 命名放在本目录，不受影响。

注意：这些 skill 来自私有、商业许可的 tongyun-skills-plus。项目若公开，这里的 tong-* 正文也会跟着公开。
MD

# 保证各 Agent 入口指向同一份（已存在则不动）
for link in .claude/skills .cursor/skills; do
  p="$PROJECT/$link"
  if [[ -L "$p" || ! -e "$p" ]]; then
    mkdir -p "$(dirname "$p")"
    ln -sfn ../.agents/skills "$p"
  else
    warn "$link 是真实目录，未改成软链；建议手动删掉后重跑（旧版 install-coding-skills 留下的）"
  fi
done

echo "sync-skills: 已同步 7 个 Coding skill 到 ${DEST}（源 $SRC_URL @ ${HEAD_SHA:0:7}）"

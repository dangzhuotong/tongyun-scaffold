#!/usr/bin/env bash
# 把 tongyun-skills-plus 的 Coding 套装装进「当前项目」的 skills 目录（项目级，不灌本机全局）
set -euo pipefail

SKILLS=(
  tong-project-pro
  tong-product-pro
  tong-ui-design-pro
  tong-api-pro
  tong-test-pro
  tong-code-review-pro
  tong-deploy-pro
)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_URL="${TONGYUN_SKILLS_PLUS_GIT:-git@github.com:dangzhuotong/tongyun-skills-plus.git}"
CACHE="${TONGYUN_SKILLS_PLUS:-$HOME/.cache/tongyun-skills-plus}"

if [[ -d "${TONGYUN_SKILLS_PLUS:-}/skills" ]]; then
  SRC="$TONGYUN_SKILLS_PLUS"
elif [[ -d "$CACHE/skills" ]]; then
  SRC="$CACHE"
  if [[ -d "$CACHE/.git" ]]; then
    git -C "$CACHE" pull --ff-only || true
  fi
else
  mkdir -p "$(dirname "$CACHE")"
  echo "cloning skills-plus (private：需 SSH 已登录 GitHub) …"
  git clone "$REPO_URL" "$CACHE"
  SRC="$CACHE"
fi

# 默认：项目内 .cursor/skills 与 .agents/skills（Cursor / 通用 Agent）
# 禁止默认写 ~/.cursor/skills 等全局目录——那是工作机/个人全局配置，不归项目脚手架管
if [[ -n "${TONGYUN_SKILLS_TARGETS:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=($TONGYUN_SKILLS_TARGETS)
else
  TARGETS=("$ROOT/.cursor/skills" "$ROOT/.agents/skills")
fi

for dest in "${TARGETS[@]}"; do
  mkdir -p "$dest"
  for name in "${SKILLS[@]}"; do
    from="$SRC/skills/$name"
    if [[ ! -f "$from/SKILL.md" ]]; then
      echo "missing $from/SKILL.md" >&2
      exit 1
    fi
    ln -sfn "$from" "$dest/$name"
    echo "linked $dest/$name"
  done
done

echo "ok. 项目级 skills 已就位（源：${SRC}）。在打开本仓库的 Agent 会话里可用；不要装进本机全局 skills。"

#!/usr/bin/env bash
# 把 tongyun-skills-plus 的 coding 套装 7 个技能链到本机 Agent skills 目录
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
  if [[ -d "$CACHE/.git" ]]; then
    git -C "$CACHE" pull --ff-only
  else
    echo "cloning skills-plus (private：需本机已登录 GitHub) …"
    git clone "$REPO_URL" "$CACHE"
  fi
  SRC="$CACHE"
fi

TARGETS=()
if [[ -n "${TONGYUN_SKILLS_TARGETS:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=($TONGYUN_SKILLS_TARGETS)
else
  TARGETS+=("$HOME/.cursor/skills")
  [[ -d "$HOME/.workbuddy" ]] && TARGETS+=("$HOME/.workbuddy/skills")
  [[ -d "$HOME/.codex" ]] && TARGETS+=("$HOME/.codex/skills")
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

echo "ok. 重开 Agent 对话后可用。skills-plus 源：$SRC"

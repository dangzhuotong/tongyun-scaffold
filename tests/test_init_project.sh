#!/usr/bin/env bash
# init-project.sh 专项测试：参数解析、环境变量、模板渲染、软链保护与安全边界。
# 离线运行，使用假仓 fixture 与临时目录，不访问网络，兼容 bash 3.2+。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT_SH="$ROOT/scripts/init-project.sh"
[[ -f "$INIT_SH" ]] || { echo "未找到 $INIT_SH" >&2; exit 1; }

fail() { echo "test_init_project 断言失败：$*" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export HOME="$WORK/home"
mkdir -p "$HOME"
unset TONGYUN_SKILLS_PLUS TONGYUN_SKILLS_CACHE TONGYUN_SKILLS_PLUS_GIT TONGYUN_SKILLS_EDITION \
  TONGYUN_SKILLS_LITE TONGYUN_SKILLS_LITE_CACHE TONGYUN_SKILLS_LITE_GIT SKIP_SKILLS_SYNC FORCE || true

# 准备轻量 fake lite 仓 fixture
FAKE_LITE="$WORK/fake-lite"
mkdir -p "$FAKE_LITE/skills"
for name in tong-project tong-product tong-ui-design tong-api tong-test tong-code-review tong-deploy; do
  mkdir -p "$FAKE_LITE/skills/$name"
  printf -- '---\nname: %s\n---\n# %s\n' "$name" "$name" > "$FAKE_LITE/skills/$name/SKILL.md"
done
git -C "$FAKE_LITE" init -q
git -C "$FAKE_LITE" -c user.name=t -c user.email=t@t add -A
git -C "$FAKE_LITE" -c user.name=t -c user.email=t@t commit -qm fixture
export TONGYUN_SKILLS_LITE="$FAKE_LITE"

# 准备轻量 fake pro 仓 fixture
FAKE_PRO="$WORK/fake-pro"
mkdir -p "$FAKE_PRO/skills"
for name in tong-project-pro tong-product-pro tong-ui-design-pro tong-api-pro tong-test-pro tong-code-review-pro tong-deploy-pro; do
  mkdir -p "$FAKE_PRO/skills/$name"
  printf -- '---\nname: %s\n---\n# %s\n' "$name" "$name" > "$FAKE_PRO/skills/$name/SKILL.md"
done
git -C "$FAKE_PRO" init -q
git -C "$FAKE_PRO" -c user.name=t -c user.email=t@t add -A
git -C "$FAKE_PRO" -c user.name=t -c user.email=t@t commit -qm fixture
export TONGYUN_SKILLS_PLUS="$FAKE_PRO"

echo "[test_init_project] 1. --edition 参数缺失或非法时退出码为 2"
# 缺少参数
status=0
out_missing="$(bash "$INIT_SH" --edition 2>&1)" || status=$?
[[ "$status" -eq 2 ]] || fail "--edition 缺少参数时退出码应为 2，实际为 $status"
grep -Fq -- "--edition 需要 lite 或 pro" <<< "$out_missing" || fail "未提示 --edition 需要 lite 或 pro"

# 非法版本（等号语法）
status=0
out_invalid="$(bash "$INIT_SH" --edition=invalid mypkg "desc" "$WORK/p_err" 2>&1)" || status=$?
[[ "$status" -eq 2 ]] || fail "--edition=invalid 退出码应为 2，实际为 $status"
grep -Fq "版本只能是 lite 或 pro" <<< "$out_invalid" || fail "未提示版本只能是 lite 或 pro"

echo "[test_init_project] 2. SKIP_SKILLS_SYNC=1 跳过 skill 同步"
P_SKIP="$WORK/p_skip"
out_skip="$(SKIP_SKILLS_SYNC=1 bash "$INIT_SH" "skip-pkg" "skip-desc" "$P_SKIP")"
grep -Fq "已跳过 skill 同步（SKIP_SKILLS_SYNC=1）" <<< "$out_skip" || fail "未打印 SKIP_SKILLS_SYNC 提示"
[[ -f "$P_SKIP/AGENTS.md" ]] || fail "缺少 AGENTS.md"
[[ -f "$P_SKIP/docs/prd.md" ]] || fail "缺少 docs/prd.md"
[[ -x "$P_SKIP/scripts/sync-skills.sh" ]] || fail "缺少可执行的 sync-skills.sh"
[[ ! -e "$P_SKIP/.agents/skills/tong-project" ]] || fail "SKIP_SKILLS_SYNC=1 时不应复制 skill"
[[ ! -e "$P_SKIP/.agents/skills/SOURCES.md" ]] || fail "SKIP_SKILLS_SYNC=1 时不应生成 SOURCES.md"

echo "[test_init_project] 3. --edition=pro 等号形式传参"
P_EQ_PRO="$WORK/p_eq_pro"
bash "$INIT_SH" --edition=pro "eq-pro-pkg" "eq-pro-desc" "$P_EQ_PRO"
[[ -f "$P_EQ_PRO/.agents/skills/tong-project-pro/SKILL.md" ]] || fail "--edition=pro 未复制 tong-project-pro"
grep -qx -- "- edition: pro" "$P_EQ_PRO/.agents/skills/SOURCES.md" || fail "SOURCES.md 未记录 edition: pro"
grep -Fq "tong-api-pro" "$P_EQ_PRO/AGENTS.md" || fail "AGENTS.md 未替换为 pro skill 链接"

echo "[test_init_project] 4. TONGYUN_SKILLS_EDITION=pro 环境变量默认生效"
P_ENV_PRO="$WORK/p_env_pro"
TONGYUN_SKILLS_EDITION=pro bash "$INIT_SH" "env-pro-pkg" "env-pro-desc" "$P_ENV_PRO"
[[ -f "$P_ENV_PRO/.agents/skills/tong-project-pro/SKILL.md" ]] || fail "TONGYUN_SKILLS_EDITION 未生效"
grep -qx -- "- edition: pro" "$P_ENV_PRO/.agents/skills/SOURCES.md" || fail "SOURCES.md 未记录 edition: pro"

echo "[test_init_project] 5. 软链保护：已有实体文件 CLAUDE.md 不被破坏"
P_REAL_FILE="$WORK/p_real_file"
mkdir -p "$P_REAL_FILE"
echo "custom claude instruction" > "$P_REAL_FILE/CLAUDE.md"
out_link="$(bash "$INIT_SH" "real-file-pkg" "desc" "$P_REAL_FILE")"
grep -Fq "跳过" <<< "$out_link" || fail "未提示跳过已存在的实体文件"
[[ ! -L "$P_REAL_FILE/CLAUDE.md" ]] || fail "实体 CLAUDE.md 不应被改成软链"
[[ "$(cat "$P_REAL_FILE/CLAUDE.md")" == "custom claude instruction" ]] || fail "实体 CLAUDE.md 内容被覆盖"

echo "[test_init_project] 6. 默认参数行为（不传名、用途、目录）"
P_DEFAULT="$WORK/p_default"
mkdir -p "$P_DEFAULT"
(cd "$P_DEFAULT" && bash "$INIT_SH" >/dev/null)
grep -Fq -- "# my-project · AI 开发规则" "$P_DEFAULT/AGENTS.md" || fail "默认项目名未生效"
grep -Fq -- "（待填写项目用途）" "$P_DEFAULT/AGENTS.md" || fail "默认用途未生效"
[[ -f "$P_DEFAULT/docs/prd.md" ]] || fail "默认目录下缺少 docs/prd.md"

echo "[test_init_project] 7. 目标路径末尾带斜杠兼容处理"
P_SLASH="$WORK/p_slash/"
bash "$INIT_SH" "slash-pkg" "slash-desc" "$P_SLASH" >/dev/null
[[ -f "$WORK/p_slash/AGENTS.md" ]] || fail "末尾带斜杠路径未正确处理"

echo "[test_init_project] 8. 默认 .gitignore 内容生成"
P_GI="$WORK/p_gitignore"
bash "$INIT_SH" "gi-pkg" "gi-desc" "$P_GI" >/dev/null
grep -qxF "node_modules/" "$P_GI/.gitignore" || fail "默认 .gitignore 缺 node_modules/"
grep -qxF ".env" "$P_GI/.gitignore" || fail "默认 .gitignore 缺 .env"
grep -qxF "!.env.example" "$P_GI/.gitignore" || fail "默认 .gitignore 缺 !.env.example"

echo "test_init_project ok"

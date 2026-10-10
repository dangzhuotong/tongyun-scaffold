#!/usr/bin/env bash
# 脚手架自检：不依赖私有 skills-plus（用假仓做 fixture），macOS bash 3.2 可跑。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT_SH="$ROOT/scripts/init-project.sh"
SKILLS="tong-project-pro tong-product-pro tong-ui-design-pro tong-api-pro tong-test-pro tong-code-review-pro tong-deploy-pro"

[[ -f "$INIT_SH" ]] || { echo "未找到 $INIT_SH" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
TMP_DIR="$WORK/p1"
TMP_DIR2="$WORK/p2"
TMP_DIR3="$WORK/p3"
FAKE="$WORK/fake-skills-plus"
mkdir -p "$TMP_DIR2"

fail() { echo "断言失败：$*" >&2; exit 1; }

# 隔离 HOME，保证不会写到/读到真实全局目录
export HOME="$WORK/home"
mkdir -p "$HOME"
unset TONGYUN_SKILLS_PLUS TONGYUN_SKILLS_CACHE TONGYUN_SKILLS_PLUS_GIT || true

echo "=== [0/7] 本仓不含 skill 正文 ==="
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git -C "$ROOT" ls-files | grep -q 'SKILL\.md$'; then
    git -C "$ROOT" ls-files | grep 'SKILL\.md$' >&2
    fail "公开脚手架仓里出现了 SKILL.md"
  fi
fi

# 假 skills-plus：每个 skill 带 references/ 和 tests/、临时文件
for name in $SKILLS; do
  mkdir -p "$FAKE/skills/$name/references" "$FAKE/skills/$name/tests" "$FAKE/skills/$name/agents"
  printf -- '---\nname: %s\n---\n# %s\n' "$name" "$name" > "$FAKE/skills/$name/SKILL.md"
  echo ref > "$FAKE/skills/$name/references/a.md"
  echo 'x: 1' > "$FAKE/skills/$name/agents/openai.yaml"
  echo test > "$FAKE/skills/$name/tests/test_x.py"
  echo junk > "$FAKE/skills/$name/run.log"
done
git -C "$FAKE" init -q
git -C "$FAKE" -c user.name=t -c user.email=t@t add -A
git -C "$FAKE" -c user.name=t -c user.email=t@t commit -qm fixture
git -C "$FAKE" remote add origin https://user:secret@example.com/fake/skills-plus.git
FAKE_SHA="$(git -C "$FAKE" rev-parse HEAD)"
export TONGYUN_SKILLS_PLUS="$FAKE"

echo "=== [1/7] 初始生成、特殊字符、skill 复制 ==="
TEST_NAME="smoke/demo & test\\1 | pipe"
TEST_PURPOSE="测试 & 用途|x \\backslash /slash"

bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR"

for file in AGENTS.md docs/prd.md docs/plan.md docs/architecture.md docs/development.md docs/user-flows.md \
  docs/skills.md docs/testing/acceptance-tests.md docs/decisions/0001-lightweight-ddd.md docs/design/README.md \
  .agents/notes/README.md scripts/sync-skills.sh .gitignore .agents/skills/SOURCES.md; do
  [[ -f "$TMP_DIR/$file" ]] || fail "缺少 $file"
done
[[ -x "$TMP_DIR/scripts/sync-skills.sh" ]] || fail "sync-skills.sh 不可执行"
for state in proposed implemented rejected archived; do
  [[ -f "$TMP_DIR/.agents/notes/$state/.gitkeep" ]] || fail "缺少 .agents/notes/$state/.gitkeep"
done
for name in $SKILLS; do
  f="$TMP_DIR/.agents/skills/$name/SKILL.md"
  [[ -f "$f" && ! -L "$f" && ! -L "$TMP_DIR/.agents/skills/$name" ]] || fail "$name 不是真实文件"
  [[ -f "$TMP_DIR/.agents/skills/$name/references/a.md" ]] || fail "$name references 未复制"
  [[ -f "$TMP_DIR/.agents/skills/$name/agents/openai.yaml" ]] || fail "$name agents 未复制"
  [[ ! -e "$TMP_DIR/.agents/skills/$name/tests" ]] || fail "$name tests 未排除"
  [[ ! -e "$TMP_DIR/.agents/skills/$name/run.log" ]] || fail "$name 临时文件未排除"
  [[ -f "$TMP_DIR/.claude/skills/$name/SKILL.md" ]] || fail ".claude/skills 未解析到 $name"
  [[ -f "$TMP_DIR/.cursor/skills/$name/SKILL.md" ]] || fail ".cursor/skills 未解析到 $name"
done
[[ "$(readlink "$TMP_DIR/.claude/skills")" == "../.agents/skills" ]] || fail ".claude/skills 软链不对"
[[ "$(readlink "$TMP_DIR/.cursor/skills")" == "../.agents/skills" ]] || fail ".cursor/skills 软链不对"
[[ "$(readlink "$TMP_DIR/CLAUDE.md")" == "AGENTS.md" ]] || fail "CLAUDE.md 不是指向 AGENTS.md 的软链"
grep -Fq "$FAKE_SHA" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 缺 commit SHA"
! grep -Fq "secret" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 泄露了 URL 凭据"
grep -qE '^\.(agents|cursor|claude)/skills/?$' "$TMP_DIR/.gitignore" && fail ".gitignore 不应忽略 skills"
[[ ! -e "$HOME/.cursor" && ! -e "$HOME/.codex" && ! -e "$HOME/.workbuddy" ]] || fail "写到了全局目录"

if grep -rn "{{" "$TMP_DIR" --exclude-dir=.agents >/dev/null 2>&1; then
  grep -rn "{{" "$TMP_DIR" --exclude-dir=.agents >&2
  fail "存在未替换的模板占位符 {{"
fi
grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/AGENTS.md" || fail "AGENTS.md 未原样保留用途"
grep -Fq -- "$TEST_NAME" "$TMP_DIR/AGENTS.md" || fail "AGENTS.md 未原样保留项目名"
grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/docs/prd.md" || fail "docs/prd.md 未原样保留用途"

if command -v git >/dev/null 2>&1; then
  git -C "$TMP_DIR" init -q
  git -C "$TMP_DIR" add -A
  for name in $SKILLS; do
    git -C "$TMP_DIR" ls-files --error-unmatch ".agents/skills/$name/SKILL.md" >/dev/null 2>&1 || fail "git add 没收录 $name/SKILL.md"
  done
fi

echo "=== [2/7] 二次运行不覆盖已改动的文件，skill 原地刷新 ==="
echo "MODIFIED_BY_TEST" > "$TMP_DIR/AGENTS.md"
echo "local edit" >> "$TMP_DIR/.agents/skills/tong-api-pro/SKILL.md"
mkdir -p "$TMP_DIR/.agents/skills/demo-pre-push-checks"
echo "# mine" > "$TMP_DIR/.agents/skills/demo-pre-push-checks/SKILL.md"
SKIP_OUTPUT="$(bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR")"
printf "%s\n" "$SKIP_OUTPUT"
grep -Fq "跳过" <<< "$SKIP_OUTPUT" || fail "二次运行未提示跳过"
[[ "$(cat "$TMP_DIR/AGENTS.md")" == "MODIFIED_BY_TEST" ]] || fail "二次运行覆盖了 AGENTS.md"
! grep -Fq "local edit" "$TMP_DIR/.agents/skills/tong-api-pro/SKILL.md" || fail "tong-* 未被刷新"
[[ -f "$TMP_DIR/.agents/skills/demo-pre-push-checks/SKILL.md" ]] || fail "项目自有 skill 被删了"

echo "=== [3/7] FORCE=1 覆盖 ==="
FORCE=1 bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR"
grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/AGENTS.md" || fail "FORCE=1 未覆盖 AGENTS.md"

echo "=== [4/7] 旧 .gitignore 里的 skills 忽略规则被移除，自定义规则保留 ==="
printf 'existing_custom_rule\n.cursor/skills/\n.agents/skills/\n' > "$TMP_DIR2/.gitignore"
bash "$INIT_SH" "demo2" "purpose2" "$TMP_DIR2"
grep -qxF "existing_custom_rule" "$TMP_DIR2/.gitignore" || fail "自定义规则丢失"
grep -qE '^\.(agents|cursor|claude)/skills/?$' "$TMP_DIR2/.gitignore" && fail "旧 skills 忽略规则未移除"

echo "=== [5/7] 拿不到 skills-plus 时 init 仍成功并警告 ==="
OUT="$(TONGYUN_SKILLS_PLUS='' TONGYUN_SKILLS_CACHE="$WORK/nocache" TONGYUN_SKILLS_PLUS_GIT="$WORK/nonexistent" \
  bash "$INIT_SH" "demo3" "purpose3" "$TMP_DIR3" 2>&1)" || fail "skills-plus 不可达时 init 失败了"
printf "%s\n" "$OUT"
grep -Fq "sync-skills.sh" <<< "$OUT" || fail "未提示之后运行 sync-skills.sh"
[[ -f "$TMP_DIR3/AGENTS.md" && -x "$TMP_DIR3/scripts/sync-skills.sh" ]] || fail "降级时项目文件不全"
[[ ! -e "$WORK/nocache" ]] || fail "clone 失败后留下了残缺缓存"

echo "=== [6/7] 拒绝对脚手架仓本身同步 / 初始化 ==="
if bash "$ROOT/scripts/sync-skills.sh" "$ROOT" >/dev/null 2>&1; then fail "sync-skills 对脚手架本身执行了"; fi
if bash "$INIT_SH" x y "$ROOT" >/dev/null 2>&1; then fail "init 允许初始化到脚手架本身"; fi

echo "=== [7/7] 未写全局目录 ==="
[[ ! -e "$HOME/.cursor" && ! -e "$HOME/.codex" && ! -e "$HOME/.workbuddy" ]] || fail "写到了全局目录"

echo "selftest ok"

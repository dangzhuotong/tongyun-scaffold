#!/usr/bin/env bash
# 脚手架自检：不依赖 lite 仓和私有 skills-plus（都用假仓做 fixture），macOS bash 3.2 可跑。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT_SH="$ROOT/scripts/init-project.sh"
PRO_SKILLS="tong-project-pro tong-product-pro tong-ui-design-pro tong-api-pro tong-test-pro tong-code-review-pro tong-deploy-pro"
LITE_SKILLS="tong-project tong-product tong-ui-design tong-api tong-test tong-code-review tong-deploy"

[[ -f "$INIT_SH" ]] || { echo "未找到 $INIT_SH" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
TMP_DIR="$WORK/p1"
TMP_DIR2="$WORK/p2"
TMP_DIR3="$WORK/p3"
TMP_DIR4="$WORK/p4"
FAKE="$WORK/fake-skills-plus"
FAKE_LITE="$WORK/fake-skills-lite"
mkdir -p "$TMP_DIR2"

fail() { echo "断言失败：$*" >&2; exit 1; }

# 隔离 HOME，保证不会写到/读到真实全局目录
export HOME="$WORK/home"
mkdir -p "$HOME"
unset TONGYUN_SKILLS_PLUS TONGYUN_SKILLS_CACHE TONGYUN_SKILLS_PLUS_GIT TONGYUN_SKILLS_EDITION \
  TONGYUN_SKILLS_LITE TONGYUN_SKILLS_LITE_CACHE TONGYUN_SKILLS_LITE_GIT || true

# AGENTS.md 里点名的 .agents/skills/<x>/SKILL.md 链接必须全部能打开
check_agents_links() { # $1=项目目录 $2=应出现的 skill 列表
  local dir="$1" name
  for name in $2; do
    grep -Fq "](.agents/skills/$name/SKILL.md)" "$dir/AGENTS.md" || fail "AGENTS.md 没点名 $name"
  done
  grep -o '](\.agents/skills/[^)]*)' "$dir/AGENTS.md" | sed -e 's/^](//' -e 's/)$//' | while read -r rel; do
    [[ -f "$dir/$rel" ]] || fail "AGENTS.md 链接打不开：$rel"
  done
}

echo "=== [0/12] 本仓不含 skill 正文 ==="
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git -C "$ROOT" ls-files | grep -q 'SKILL\.md$'; then
    git -C "$ROOT" ls-files | grep 'SKILL\.md$' >&2
    fail "公开脚手架仓里出现了 SKILL.md"
  fi
fi

# 假仓：每个 skill 带 references/ 和 tests/、临时文件
make_fake() { # $1=目录 $2=skill 列表 $3=origin
  local dir="$1" name
  for name in $2; do
    mkdir -p "$dir/skills/$name/references" "$dir/skills/$name/tests" "$dir/skills/$name/agents"
    printf -- '---\nname: %s\n---\n# %s\n' "$name" "$name" > "$dir/skills/$name/SKILL.md"
    echo ref > "$dir/skills/$name/references/a.md"
    echo 'x: 1' > "$dir/skills/$name/agents/openai.yaml"
    echo test > "$dir/skills/$name/tests/test_x.py"
    echo junk > "$dir/skills/$name/run.log"
  done
  git -C "$dir" init -q
  git -C "$dir" -c user.name=t -c user.email=t@t add -A
  git -C "$dir" -c user.name=t -c user.email=t@t commit -qm fixture
  git -C "$dir" remote add origin "$3"
}
make_fake "$FAKE" "$PRO_SKILLS" https://user:secret@example.com/fake/skills-plus.git
make_fake "$FAKE_LITE" "$LITE_SKILLS" https://example.com/fake/skills-lite.git
FAKE_SHA="$(git -C "$FAKE" rev-parse HEAD)"
LITE_SHA="$(git -C "$FAKE_LITE" rev-parse HEAD)"
export TONGYUN_SKILLS_PLUS="$FAKE"
export TONGYUN_SKILLS_LITE="$FAKE_LITE"

echo "=== [1/12] 初始生成（默认 lite）、特殊字符、skill 复制 ==="
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
for name in $LITE_SKILLS; do
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
for name in $PRO_SKILLS; do
  [[ ! -e "$TMP_DIR/.agents/skills/$name" ]] || fail "默认 lite 却装了 $name"
done
grep -qx -- "- edition: lite" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 没记 edition: lite"
grep -Fq "$LITE_SHA" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 缺 lite commit SHA"
check_agents_links "$TMP_DIR" "$LITE_SKILLS"
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
  for name in $LITE_SKILLS; do
    git -C "$TMP_DIR" ls-files --error-unmatch ".agents/skills/$name/SKILL.md" >/dev/null 2>&1 || fail "git add 没收录 $name/SKILL.md"
  done
fi

echo "=== [2/12] 二次运行不覆盖已改动的文件，skill 原地刷新 ==="
echo "MODIFIED_BY_TEST" > "$TMP_DIR/AGENTS.md"
echo "local edit" >> "$TMP_DIR/.agents/skills/tong-api/SKILL.md"
mkdir -p "$TMP_DIR/.agents/skills/demo-pre-push-checks"
echo "# mine" > "$TMP_DIR/.agents/skills/demo-pre-push-checks/SKILL.md"
SKIP_OUTPUT="$(bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR")"
printf "%s\n" "$SKIP_OUTPUT"
grep -Fq "跳过" <<< "$SKIP_OUTPUT" || fail "二次运行未提示跳过"
[[ "$(cat "$TMP_DIR/AGENTS.md")" == "MODIFIED_BY_TEST" ]] || fail "二次运行覆盖了 AGENTS.md"
! grep -Fq "local edit" "$TMP_DIR/.agents/skills/tong-api/SKILL.md" || fail "tong-* 未被刷新"
[[ -f "$TMP_DIR/.agents/skills/demo-pre-push-checks/SKILL.md" ]] || fail "项目自有 skill 被删了"

echo "=== [3/12] FORCE=1 覆盖 ==="
FORCE=1 bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR"
grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/AGENTS.md" || fail "FORCE=1 未覆盖 AGENTS.md"
check_agents_links "$TMP_DIR" "$LITE_SKILLS"

echo "=== [4/12] lite → pro 切换，再切回 lite ==="
bash "$TMP_DIR/scripts/sync-skills.sh" --edition pro "$TMP_DIR"
for name in $PRO_SKILLS; do
  [[ -f "$TMP_DIR/.agents/skills/$name/SKILL.md" ]] || fail "切 pro 后缺 $name"
  [[ ! -e "$TMP_DIR/.agents/skills/$name/tests" ]] || fail "$name tests 未排除"
done
for name in $LITE_SKILLS; do
  [[ ! -e "$TMP_DIR/.agents/skills/$name" ]] || fail "切 pro 后 lite 的 $name 没删"
done
[[ -f "$TMP_DIR/.agents/skills/demo-pre-push-checks/SKILL.md" ]] || fail "切版本删了项目自有 skill"
grep -qx -- "- edition: pro" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 没记 edition: pro"
grep -Fq "$FAKE_SHA" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 缺 pro commit SHA"
! grep -Fq "secret" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "SOURCES.md 泄露了 URL 凭据"
check_agents_links "$TMP_DIR" "$PRO_SKILLS"
# 不带参数重跑：沿用上次的 pro
bash "$TMP_DIR/scripts/sync-skills.sh" "$TMP_DIR"
grep -qx -- "- edition: pro" "$TMP_DIR/.agents/skills/SOURCES.md" || fail "重跑没沿用 pro"
# 环境变量切回 lite
TONGYUN_SKILLS_EDITION=lite bash "$TMP_DIR/scripts/sync-skills.sh" "$TMP_DIR"
for name in $PRO_SKILLS; do
  [[ ! -e "$TMP_DIR/.agents/skills/$name" ]] || fail "切回 lite 后 $name 没删"
done
check_agents_links "$TMP_DIR" "$LITE_SKILLS"
# 非法版本
if bash "$TMP_DIR/scripts/sync-skills.sh" --edition gold "$TMP_DIR" >/dev/null 2>&1; then fail "接受了非法版本"; fi

echo "=== [5/12] init --edition pro ==="
bash "$INIT_SH" --edition pro "demo4" "purpose4" "$TMP_DIR4"
for name in $PRO_SKILLS; do
  [[ -f "$TMP_DIR4/.agents/skills/$name/SKILL.md" ]] || fail "init pro 缺 $name"
done
check_agents_links "$TMP_DIR4" "$PRO_SKILLS"
if bash "$INIT_SH" --edition gold x y "$WORK/p5" >/dev/null 2>&1; then fail "init 接受了非法版本"; fi

echo "=== [6/12] 旧 .gitignore 里的 skills 忽略规则被移除，自定义规则保留 ==="
printf 'existing_custom_rule\n.cursor/skills/\n.agents/skills/\n' > "$TMP_DIR2/.gitignore"
bash "$INIT_SH" "demo2" "purpose2" "$TMP_DIR2"
grep -qxF "existing_custom_rule" "$TMP_DIR2/.gitignore" || fail "自定义规则丢失"
grep -qE '^\.(agents|cursor|claude)/skills/?$' "$TMP_DIR2/.gitignore" && fail "旧 skills 忽略规则未移除"

echo "=== [7/12] 拿不到来源仓时 init 仍成功并警告（lite / pro） ==="
OUT="$(TONGYUN_SKILLS_LITE='' TONGYUN_SKILLS_LITE_CACHE="$WORK/nocache-lite" TONGYUN_SKILLS_LITE_GIT="$WORK/nonexistent" \
  bash "$INIT_SH" "demo3" "purpose3" "$TMP_DIR3" 2>&1)" || fail "lite 仓不可达时 init 失败了"
printf "%s\n" "$OUT"
grep -Fq "sync-skills.sh" <<< "$OUT" || fail "未提示之后运行 sync-skills.sh"
[[ -f "$TMP_DIR3/AGENTS.md" && -x "$TMP_DIR3/scripts/sync-skills.sh" ]] || fail "降级时项目文件不全"
[[ ! -e "$WORK/nocache-lite" ]] || fail "clone 失败后留下了残缺缓存"
OUT="$(TONGYUN_SKILLS_PLUS='' TONGYUN_SKILLS_CACHE="$WORK/nocache" TONGYUN_SKILLS_PLUS_GIT="$WORK/nonexistent" \
  bash "$INIT_SH" --edition pro "demo3b" "purpose3b" "$WORK/p3b" 2>&1)" || fail "skills-plus 不可达时 init 失败了"
grep -Fq "edition pro" <<< "$OUT" || fail "pro 降级未提示 --edition pro"
[[ ! -e "$WORK/nocache" ]] || fail "clone 失败后留下了残缺缓存"
check_agents_links_names_only() { grep -Fq "](.agents/skills/tong-api-pro/SKILL.md)" "$1/AGENTS.md"; }
check_agents_links_names_only "$WORK/p3b" || fail "pro 同步失败时 AGENTS.md 没写 pro 名字"

echo "=== [8/12] 拒绝对脚手架仓本身同步 / 初始化 ==="
if bash "$ROOT/scripts/sync-skills.sh" "$ROOT" >/dev/null 2>&1; then fail "sync-skills 对脚手架本身执行了"; fi
if bash "$ROOT/scripts/sync-skills.sh" --edition pro "$ROOT" >/dev/null 2>&1; then fail "sync-skills pro 对脚手架本身执行了"; fi
if bash "$INIT_SH" x y "$ROOT" >/dev/null 2>&1; then fail "init 允许初始化到脚手架本身"; fi

echo "=== [9/12] 未写全局目录 ==="
[[ ! -e "$HOME/.cursor" && ! -e "$HOME/.codex" && ! -e "$HOME/.workbuddy" ]] || fail "写到了全局目录"

echo "=== [10/12] init-project 专项测试（tests/test_init_project.sh） ==="
bash "$ROOT/tests/test_init_project.sh"

echo "=== [11/12] sync-skills 专项测试（tests/test_sync_skills.sh） ==="
bash "$ROOT/tests/test_sync_skills.sh"

echo "=== [12/12] 本仓仍不含 skill 正文 ==="
[[ ! -e "$ROOT/.agents/skills/tong-project" && ! -e "$ROOT/.agents/skills/tong-project-pro" ]] || fail "脚手架目录里出现了 skill"

echo "selftest ok"

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INIT_SH="$ROOT/scripts/init-project.sh"

[[ -f "$INIT_SH" ]] || { echo "未找到 $INIT_SH" >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
TMP_DIR2="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR" "$TMP_DIR2"
}
trap cleanup EXIT

echo "=== [1/5] 测试初始生成与特殊字符处理 ==="
TEST_NAME="smoke/demo & test\\1 | pipe"
TEST_PURPOSE="测试 & 用途|x \\backslash /slash"

bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR"

REQUIRED_FILES=(
  "AGENTS.md"
  "docs/prd.md"
  "docs/plan.md"
  "docs/architecture.md"
  "docs/development.md"
  "docs/user-flows.md"
  "docs/skills.md"
  "docs/testing/acceptance-tests.md"
  "docs/decisions/0001-lightweight-ddd.md"
  "docs/design/README.md"
  "scripts/install-coding-skills.sh"
  ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$TMP_DIR/$file" ]]; then
    echo "断言失败：缺少必要文件 $file" >&2
    exit 1
  fi
done

if [[ ! -x "$TMP_DIR/scripts/install-coding-skills.sh" ]]; then
  echo "断言失败：scripts/install-coding-skills.sh 不可执行" >&2
  exit 1
fi

if ! grep -qxF ".cursor/skills/" "$TMP_DIR/.gitignore"; then
  echo "断言失败：.gitignore 中缺少 .cursor/skills/" >&2
  exit 1
fi

if ! grep -qxF ".agents/skills/" "$TMP_DIR/.gitignore"; then
  echo "断言失败：.gitignore 中缺少 .agents/skills/" >&2
  exit 1
fi

if grep -rn "{{" "$TMP_DIR" >/dev/null 2>&1; then
  echo "断言失败：存在未替换的模板占位符 {{" >&2
  grep -rn "{{" "$TMP_DIR" >&2
  exit 1
fi

if ! grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/AGENTS.md"; then
  echo "断言失败：AGENTS.md 中未原样保留特殊字符用途" >&2
  exit 1
fi

if ! grep -Fq -- "$TEST_NAME" "$TMP_DIR/AGENTS.md"; then
  echo "断言失败：AGENTS.md 中未原样保留特殊字符项目名" >&2
  exit 1
fi

if ! grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/docs/prd.md"; then
  echo "断言失败：docs/prd.md 中未原样保留特殊字符用途" >&2
  exit 1
fi

echo "=== [2/5] 测试二次运行不覆盖已改动的文件 ==="
MODIFIED_MARKER="MODIFIED_BY_TEST"
echo "$MODIFIED_MARKER" > "$TMP_DIR/AGENTS.md"

SKIP_OUTPUT="$(bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR")"
printf "%s\n" "$SKIP_OUTPUT"
if ! grep -Fq "跳过" <<< "$SKIP_OUTPUT" || ! grep -Fq "（已存在）" <<< "$SKIP_OUTPUT"; then
  echo "断言失败：二次运行未提示「跳过 xxx（已存在）」" >&2
  exit 1
fi

CURRENT_CONTENT="$(cat "$TMP_DIR/AGENTS.md")"
if [[ "$CURRENT_CONTENT" != "$MODIFIED_MARKER" ]]; then
  echo "断言失败：二次运行覆盖了已修改的 AGENTS.md" >&2
  exit 1
fi

echo "=== [3/5] 测试 FORCE=1 覆盖已存在文件 ==="
FORCE=1 bash "$INIT_SH" "$TEST_NAME" "$TEST_PURPOSE" "$TMP_DIR"

OVERWRITTEN_CONTENT="$(cat "$TMP_DIR/AGENTS.md")"
if [[ "$OVERWRITTEN_CONTENT" == "$MODIFIED_MARKER" ]]; then
  echo "断言失败：FORCE=1 未能覆盖已修改的 AGENTS.md" >&2
  exit 1
fi

if ! grep -Fq -- "$TEST_PURPOSE" "$TMP_DIR/AGENTS.md"; then
  echo "断言失败：FORCE=1 覆盖后内容缺少目标用途" >&2
  exit 1
fi

echo "=== [4/5] 测试已有 .gitignore 仅追加缺漏行且不重复追加 ==="
printf 'existing_custom_rule\n' > "$TMP_DIR2/.gitignore"

bash "$INIT_SH" "demo2" "purpose2" "$TMP_DIR2"

if ! grep -qxF "existing_custom_rule" "$TMP_DIR2/.gitignore"; then
  echo "断言失败：已有 .gitignore 中的 custom rule 丢失" >&2
  exit 1
fi

if ! grep -qxF ".cursor/skills/" "$TMP_DIR2/.gitignore"; then
  echo "断言失败：已有 .gitignore 未被追加 .cursor/skills/" >&2
  exit 1
fi

if ! grep -qxF ".agents/skills/" "$TMP_DIR2/.gitignore"; then
  echo "断言失败：已有 .gitignore 未被追加 .agents/skills/" >&2
  exit 1
fi

# 再次运行，断言不重复追加
bash "$INIT_SH" "demo2" "purpose2" "$TMP_DIR2"

COUNT_CURSOR="$(grep -cxF ".cursor/skills/" "$TMP_DIR2/.gitignore")"
COUNT_AGENTS="$(grep -cxF ".agents/skills/" "$TMP_DIR2/.gitignore")"

if [[ "$COUNT_CURSOR" -ne 1 || "$COUNT_AGENTS" -ne 1 ]]; then
  echo "断言失败：.gitignore 中出现重复规则（cursor=$COUNT_CURSOR, agents=$COUNT_AGENTS）" >&2
  exit 1
fi

echo "=== [5/5] 验证未误调用 install-coding-skills.sh ==="
if [[ -d "$TMP_DIR/.cursor/skills" || -d "$TMP_DIR2/.cursor/skills" ]]; then
  echo "断言失败：临时目录中出现了 skills 软链目录，疑似误调用了 install-coding-skills.sh" >&2
  exit 1
fi

echo "selftest ok"

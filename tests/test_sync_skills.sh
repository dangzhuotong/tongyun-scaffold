#!/usr/bin/env bash
# sync-skills.sh 专项测试：CLI 参数解析、错误退出码、排除规则、软链实体化、脏工作区检测与已有目录保护。
# 离线运行，使用假仓 fixture 与临时目录，不访问网络，兼容 bash 3.2+。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SYNC_SH="$ROOT/scripts/sync-skills.sh"
[[ -f "$SYNC_SH" ]] || { echo "未找到 $SYNC_SH" >&2; exit 1; }

fail() { echo "test_sync_skills 断言失败：$*" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export HOME="$WORK/home"
mkdir -p "$HOME"
unset TONGYUN_SKILLS_PLUS TONGYUN_SKILLS_CACHE TONGYUN_SKILLS_PLUS_GIT TONGYUN_SKILLS_EDITION \
  TONGYUN_SKILLS_LITE TONGYUN_SKILLS_LITE_CACHE TONGYUN_SKILLS_LITE_GIT || true

# 准备一个包含各种测试特征的 fake lite 仓
FAKE_LITE="$WORK/fake-lite"
mkdir -p "$FAKE_LITE/skills"
LITE_SKILLS="tong-project tong-product tong-ui-design tong-api tong-test tong-code-review tong-deploy"
for name in $LITE_SKILLS; do
  mkdir -p "$FAKE_LITE/skills/$name/references" "$FAKE_LITE/skills/$name/test" "$FAKE_LITE/skills/$name/__pycache__" \
    "$FAKE_LITE/skills/$name/.pytest_cache" "$FAKE_LITE/skills/$name/tmp"
  printf -- '---\nname: %s\n---\n# %s\n' "$name" "$name" > "$FAKE_LITE/skills/$name/SKILL.md"
  echo "content-a" > "$FAKE_LITE/skills/$name/references/a.md"
  # 软链文件：应当在复制后变成真实文件
  ln -s a.md "$FAKE_LITE/skills/$name/references/link.md"
  # 应被排除的文件
  echo "junk" > "$FAKE_LITE/skills/$name/test/junk.txt"
  echo "pyc" > "$FAKE_LITE/skills/$name/references/compiled.pyc"
  echo "tmp" > "$FAKE_LITE/skills/$name/references/temp.tmp"
  echo "swp" > "$FAKE_LITE/skills/$name/references/file.swp"
  echo "tilde" > "$FAKE_LITE/skills/$name/references/backup~"
done
git -C "$FAKE_LITE" init -q
git -C "$FAKE_LITE" -c user.name=t -c user.email=t@t add -A
git -C "$FAKE_LITE" -c user.name=t -c user.email=t@t commit -qm fixture
git -C "$FAKE_LITE" remote add origin https://example.com/fake/lite.git

export TONGYUN_SKILLS_LITE="$FAKE_LITE"

# 初始化一个目标项目用于测试 sync
PROJ="$WORK/test_project"
mkdir -p "$PROJ/scripts" "$PROJ/.agents/skills"
cp "$SYNC_SH" "$PROJ/scripts/sync-skills.sh"
chmod +x "$PROJ/scripts/sync-skills.sh"
cat > "$PROJ/AGENTS.md" <<'MD'
# Test Project
- [tong-project](.agents/skills/tong-project/SKILL.md)
- [tong-api](.agents/skills/tong-api/SKILL.md)
MD

echo "[test_sync_skills] 1. 帮助参数 -h / --help（退出码 0）"
status=0
out_h="$(bash "$SYNC_SH" -h 2>&1)" || status=$?
[[ "$status" -eq 0 ]] || fail "-h 退出码应为 0，实际为 $status"
grep -Fq "用法：bash scripts/sync-skills.sh" <<< "$out_h" || fail "-h 未输出用法说明"

status=0
out_help="$(bash "$SYNC_SH" --help 2>&1)" || status=$?
[[ "$status" -eq 0 ]] || fail "--help 退出码应为 0，实际为 $status"
grep -Fq "用法：bash scripts/sync-skills.sh" <<< "$out_help" || fail "--help 未输出用法说明"

echo "[test_sync_skills] 2. 未知参数与参数错误校验（退出码 2）"
# 未知选项
status=0
out_unk="$(bash "$SYNC_SH" --unrecognized-opt "$PROJ" 2>&1)" || status=$?
[[ "$status" -eq 2 ]] || fail "未知参数退出码应为 2，实际为 $status"
grep -Fq "未知参数 --unrecognized-opt" <<< "$out_unk" || fail "未提示未知参数"

# 多余的位置参数
status=0
out_extra="$(bash "$SYNC_SH" "$PROJ" "extra_arg" 2>&1)" || status=$?
[[ "$status" -eq 2 ]] || fail "多余位置参数退出码应为 2，实际为 $status"

# --edition 缺少值
status=0
out_no_val="$(bash "$SYNC_SH" --edition 2>&1)" || status=$?
[[ "$status" -eq 2 ]] || fail "--edition 缺少值退出码应为 2，实际为 $status"

# 目标项目目录不存在
status=0
out_nodir="$(bash "$SYNC_SH" "$WORK/nonexistent_dir" 2>&1)" || status=$?
[[ "$status" -eq 2 ]] || fail "目标目录不存在时退出码应为 2，实际为 $status"
grep -Fq "项目目录不存在" <<< "$out_nodir" || fail "未提示项目目录不存在"

echo "[test_sync_skills] 3. 源目录异常处理（退出码 1）"
# 源目录缺少 skills/ 目录
BAD_SRC="$WORK/bad_src"
mkdir -p "$BAD_SRC"
status=0
out_noskills="$(TONGYUN_SKILLS_LITE="$BAD_SRC" bash "$SYNC_SH" "$PROJ" 2>&1)" || status=$?
[[ "$status" -eq 1 ]] || fail "源目录缺少 skills/ 时退出码应为 1，实际为 $status"
grep -Fq "下没有 skills/ 目录" <<< "$out_noskills" || fail "未提示没有 skills/ 目录"

# 源目录中某个 skill 缺少 SKILL.md
rm -f "$FAKE_LITE/skills/tong-api/SKILL.md"
status=0
out_noskillmd="$(bash "$SYNC_SH" "$PROJ" 2>&1)" || status=$?
[[ "$status" -eq 1 ]] || fail "源缺少 SKILL.md 时退出码应为 1，实际为 $status"
grep -Fq "源里缺" <<< "$out_noskillmd" || fail "未提示源里缺 SKILL.md"
# 恢复 SKILL.md 以供后续测试
printf -- '---\nname: tong-api\n---\n# tong-api\n' > "$FAKE_LITE/skills/tong-api/SKILL.md"

echo "[test_sync_skills] 4. 默认目标目录（不传参数时为脚本上一级）"
(cd "$PROJ" && bash "$PROJ/scripts/sync-skills.sh" >/dev/null)
[[ -f "$PROJ/.agents/skills/tong-project/SKILL.md" ]] || fail "默认目录同步未生效"
[[ -f "$PROJ/.agents/skills/SOURCES.md" ]] || fail "默认目录同步未生成 SOURCES.md"

echo "[test_sync_skills] 5. 软链展开为实体文件"
f_link="$PROJ/.agents/skills/tong-api/references/link.md"
[[ -f "$f_link" ]] || fail "引用的软链文件未被复制"
[[ ! -L "$f_link" ]] || fail "目标文件仍是软链，未能通过 -RL 展开为实体文件"
[[ "$(cat "$f_link")" == "content-a" ]] || fail "展开后的实体文件内容不符"

echo "[test_sync_skills] 6. 临时文件与排除目录（单数 test, __pycache__, tmp, *.pyc, *.swp 等）"
[[ ! -e "$PROJ/.agents/skills/tong-api/test" ]] || fail "单数 test/ 目录未被排除"
[[ ! -e "$PROJ/.agents/skills/tong-api/__pycache__" ]] || fail "__pycache__ 未被排除"
[[ ! -e "$PROJ/.agents/skills/tong-api/.pytest_cache" ]] || fail ".pytest_cache 未被排除"
[[ ! -e "$PROJ/.agents/skills/tong-api/tmp" ]] || fail "tmp 目录未被排除"
[[ ! -e "$PROJ/.agents/skills/tong-api/references/compiled.pyc" ]] || fail "*.pyc 未被删除"
[[ ! -e "$PROJ/.agents/skills/tong-api/references/temp.tmp" ]] || fail "*.tmp 未被删除"
[[ ! -e "$PROJ/.agents/skills/tong-api/references/file.swp" ]] || fail "*.swp 未被删除"
[[ ! -e "$PROJ/.agents/skills/tong-api/references/backup~" ]] || fail "*~ 未被删除"

echo "[test_sync_skills] 7. Git dirty 检测（SOURCES.md 中的 commit SHA 带 +dirty）"
echo "dirty edit" >> "$FAKE_LITE/skills/tong-api/SKILL.md"
bash "$SYNC_SH" "$PROJ" >/dev/null
grep -E '`tong-api` \| `skills/tong-api` \| `[0-9a-f]+\+dirty`' "$PROJ/.agents/skills/SOURCES.md" || fail "未在 dirty 改动后生成 +dirty 标识"
# 恢复 clean
git -C "$FAKE_LITE" checkout -- .

echo "[test_sync_skills] 8. 真实目录保护（.claude/skills 为真实目录时不覆盖为软链）"
rm -rf "$PROJ/.claude/skills"  # 前面步骤已把它建成软链，先删掉再造真实目录
mkdir -p "$PROJ/.claude/skills"
echo "custom agent file" > "$PROJ/.claude/skills/custom.txt"
out_dir="$(bash "$SYNC_SH" "$PROJ" 2>&1)"
grep -Fq ".claude/skills 是真实目录，未改成软链" <<< "$out_dir" || fail "未提示真实目录保护警告"
[[ ! -L "$PROJ/.claude/skills" ]] || fail ".claude/skills 被改成了软链"
[[ -f "$PROJ/.claude/skills/custom.txt" ]] || fail "真实目录内文件丢失"

echo "test_sync_skills ok"

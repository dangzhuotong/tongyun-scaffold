#!/usr/bin/env bash
# 离线集成回归；全部目标、缓存和来源均在临时目录，不改 HOME 或全局目录。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
unset TONGYUN_SKILLS TONGYUN_SKILLS_PLUS TONGYUN_SKILLS_GIT TONGYUN_SKILLS_PLUS_GIT \
  TONGYUN_SKILLS_EDITION SKIP_SKILLS_SYNC FORCE || true
export TONGYUN_SKILLS_CACHE="$WORK/cache"
FAKE="$WORK/source"
SKILLS="tongyun-product tongyun-ui-design tongyun-api tongyun-test tongyun-code-review tongyun-deploy tongyun-mac-ship"
fail() { echo "selftest 断言失败：$*" >&2; exit 1; }
check_links() {
  local rel
  while read -r rel; do
    [[ -f "$1/$rel" ]] || fail "AGENTS 链接缺失：$rel"
  done < <(grep -o '](\.agents/skills/[^)]*)' "$1/AGENTS.md" | sed -e 's/^](//' -e 's/)$//')
}
for name in $SKILLS; do
  mkdir -p "$FAKE/skills/$name/references" "$FAKE/skills/$name/tests"
  printf -- '---\nname: %s\n---\n' "$name" > "$FAKE/skills/$name/SKILL.md"
  echo reference > "$FAKE/skills/$name/references/a.md"
  echo test > "$FAKE/skills/$name/tests/test.txt"
done
mkdir -p "$FAKE/skills/tongyun-product/jobs/project"
echo job > "$FAKE/skills/tongyun-product/jobs/project/JOB.md"
git -C "$FAKE" init -q
git -C "$FAKE" add -A
git -C "$FAKE" -c user.name=t -c user.email=t@t commit -qm fixture
git -C "$FAKE" remote add origin https://user:secret@example.com/tongyun-skills.git
export TONGYUN_SKILLS="$FAKE"

P="$WORK/project"
bash "$ROOT/scripts/init-project.sh" 'demo & a/b' 'purpose & x/y' "$P"
grep -Fq 'demo & a/b' "$P/AGENTS.md" || fail '项目名转义'
grep -Fq 'purpose & x/y' "$P/docs/prd.md" || fail '用途转义'
for name in $SKILLS; do
  [[ -f "$P/.agents/skills/$name/SKILL.md" ]] || fail "缺 $name"
  [[ ! -e "$P/.agents/skills/$name/tests" ]] || fail '未排除 tests'
done
check_links "$P"
grep -qxF -- '- edition: tongyun' "$P/.agents/skills/SOURCES.md" || fail '来源记录'
if grep -q 'user:secret' "$P/.agents/skills/SOURCES.md"; then fail '来源凭据泄露'; fi
[[ "$(readlink "$P/CLAUDE.md")" == AGENTS.md ]] || fail 'CLAUDE 链接'
for link in .claude/skills .cursor/skills; do
  [[ "$(readlink "$P/$link")" == ../.agents/skills ]] || fail "$link"
done

# 从旧 pro/lite 目录与链接迁移，同时保护相近名称和用户自定义内容。
for old in tong-project tong-product-pro tong-api tong-api-pro; do
  mkdir -p "$P/.agents/skills/$old"
  echo old > "$P/.agents/skills/$old/SKILL.md"
done
mkdir -p "$P/.agents/skills/demo-custom" "$P/.agents/skills/tong-api-custom"
echo keep > "$P/.agents/skills/demo-custom/SKILL.md"
echo keep > "$P/.agents/skills/tong-api-custom/SKILL.md"
cat >> "$P/AGENTS.md" <<'MD'
- [tong-project](.agents/skills/tong-project/SKILL.md)
- [tong-product-pro](.agents/skills/tong-product-pro/SKILL.md)
- [custom label](.agents/skills/tong-api-pro/SKILL.md)
- [tong-api-custom](.agents/skills/tong-api-custom/SKILL.md)
[tong-api](https://example.com/custom-reference)
custom instruction remains
MD
bash "$ROOT/scripts/sync-skills.sh" --edition pro "$P"
check_links "$P"
for old in tong-project tong-product-pro tong-api tong-api-pro; do
  [[ ! -e "$P/.agents/skills/$old" ]] || fail "遗留 $old"
done
grep -Fq '[tong-api-custom](.agents/skills/tong-api-custom/SKILL.md)' "$P/AGENTS.md" || fail '误改相近名字'
grep -Fq '[tong-api](https://example.com/custom-reference)' "$P/AGENTS.md" || fail '误改其他链接标签'
grep -Fq 'custom instruction remains' "$P/AGENTS.md" || fail '误删自定义指令'
[[ -f "$P/.agents/skills/demo-custom/SKILL.md" ]] || fail '误删自定义 skill'
cp "$P/AGENTS.md" "$WORK/agents.before"
bash "$ROOT/scripts/sync-skills.sh" "$P"
cmp -s "$P/AGENTS.md" "$WORK/agents.before" || fail '重复同步不幂等'

# init 重跑保护项目规则和 gitignore；显式 FORCE 才覆盖。
printf 'custom-rule\n.agents/skills/\n' > "$P/.gitignore"
bash "$ROOT/scripts/init-project.sh" next desc "$P" > /dev/null
cmp -s "$P/AGENTS.md" "$WORK/agents.before" || fail 'init 覆盖用户规则'
grep -qxF custom-rule "$P/.gitignore" || fail '自定义 gitignore 丢失'
if grep -qxF '.agents/skills/' "$P/.gitignore"; then fail '未移除 skills 忽略'; fi
FORCE=1 bash "$ROOT/scripts/init-project.sh" next desc "$P" > /dev/null
grep -Fq '# next · AI 开发规则' "$P/AGENTS.md" || fail FORCE

# 在检查完整源之前，不清理旧 skill、不重写规则和 SOURCES。
cp "$P/.agents/skills/SOURCES.md" "$WORK/sources.before"
cp "$P/AGENTS.md" "$WORK/agents.before"
mv "$FAKE/skills/tongyun-product/jobs/project/JOB.md" "$WORK/job"
if bash "$ROOT/scripts/sync-skills.sh" "$P" > /dev/null 2>&1; then fail '缺 project JOB 应失败'; fi
cmp -s "$P/.agents/skills/SOURCES.md" "$WORK/sources.before" || fail '失败改写来源'
cmp -s "$P/AGENTS.md" "$WORK/agents.before" || fail '失败改写规则'
mv "$WORK/job" "$FAKE/skills/tongyun-product/jobs/project/JOB.md"

# lite 必须在创建目录前拒绝，不能静默安装商业技能。
if bash "$ROOT/scripts/init-project.sh" --edition lite x y "$WORK/lite" > /dev/null 2>&1; then fail '接受 lite'; fi
[[ ! -e "$WORK/lite" ]] || fail 'lite 拒绝前产生目标'
if bash "$ROOT/scripts/sync-skills.sh" --edition lite "$P" > /dev/null 2>&1; then fail 'sync 接受 lite'; fi
if bash "$ROOT/scripts/init-project.sh" x y "$ROOT" > /dev/null 2>&1; then fail '初始化脚手架本身'; fi
if bash "$ROOT/scripts/sync-skills.sh" "$ROOT" > /dev/null 2>&1; then fail '同步脚手架本身'; fi

# 不可达来源仅对初始化降级，直接同步失败；不发起网络请求。
OUT="$(TONGYUN_SKILLS='' TONGYUN_SKILLS_GIT="$WORK/missing" bash "$ROOT/scripts/init-project.sh" offline desc "$WORK/offline" 2>&1)"
grep -Fq '警告' <<< "$OUT" || fail '离线未警告'
[[ -f "$WORK/offline/AGENTS.md" && ! -e "$WORK/offline/.agents/skills/SOURCES.md" ]] || fail '离线初始化状态错误'
[[ ! -e "$TONGYUN_SKILLS_CACHE" ]] || fail '残缺缓存未清理'

bash "$ROOT/tests/test_init_project.sh"
bash "$ROOT/tests/test_sync_skills.sh"
if git -C "$ROOT" ls-files | grep -q 'SKILL\.md$'; then fail '脚手架含技能正文'; fi
# shellcheck disable=SC2016  # 正则按字面传递给 grep
if LC_ALL=C grep -nE '\$([A-Za-z_][A-Za-z0-9_]*|[0-9]+)[^ -~]' "$ROOT/scripts/"*.sh; then fail 'bash 3.2 多字节变量边界'; fi
echo 'selftest ok'

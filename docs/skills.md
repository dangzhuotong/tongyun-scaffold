# 配套开发技能（项目级 skill）

做法参考 [deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)：项目用的 skill 当源码提交在项目里的 `.agents/skills/<名字>/SKILL.md`，各家 Agent 通过软链读同一份，`AGENTS.md` 在用到的步骤里直接点名。

## 本仓（公开）只放脚本，不放 skill 正文

Coding 套装 7 个 skill（`tong-project-pro`、`tong-product-pro`、`tong-ui-design-pro`、`tong-api-pro`、`tong-test-pro`、`tong-code-review-pro`、`tong-deploy-pro`）的正文在私有、商业许可的 tongyun-skills-plus 里。脚手架只提供：

- `scripts/init-project.sh`：初始化新项目，并调用同步脚本；
- `scripts/sync-skills.sh`：把 7 个 skill 复制进**新项目**的 `.agents/skills/`。

`sync-skills.sh` 拒绝对脚手架仓本身运行；`init-project.sh` 也不允许初始化到脚手架目录。本仓 `.gitignore` 忽略 `.agents/skills/`，selftest 会检查仓里没有 `SKILL.md`。

## init 出来的项目长这样

```text
AGENTS.md                 # 各步骤点名对应 skill
CLAUDE.md -> AGENTS.md
.agents/skills/tong-*-pro/  # 真实文件，随项目提交
.agents/skills/SOURCES.md   # 来源仓 + commit SHA
.agents/notes/{proposed,implemented,rejected,archived}/
.claude/skills -> ../.agents/skills
.cursor/skills -> ../.agents/skills
scripts/sync-skills.sh
docs/...
```

## skill 来源

1. `TONGYUN_SKILLS_PLUS=/path/to/tongyun-skills-plus`（设置了就只用它）
2. `~/.cache/tongyun-skills-plus`（存在则 `git pull --ff-only`）
3. 否则 `git clone git@github.com:dangzhuotong/tongyun-skills-plus.git` 到上面的缓存（可用 `TONGYUN_SKILLS_PLUS_GIT` / `TONGYUN_SKILLS_CACHE` 改地址）

拿不到 skills-plus 时 init 照常完成，只打印警告，之后在项目里补跑 `bash scripts/sync-skills.sh`。

复制时整目录带上 `references/`、`examples/`、`assets/`、`agents/`，去掉 `tests/`、`__pycache__`、`*.log`/`*.tmp` 等；软链会被展开成真实文件。

## 更新

在项目根目录重跑 `bash scripts/sync-skills.sh`：原地覆盖 `tong-*`、重写 `SOURCES.md`。项目自己的 skill 用 `<项目名>-xxx` 命名放在同一目录，不会被动。

## 注意

- 这些 skill 是项目级的，不要装进本机全局 `~/.cursor/skills`、`~/.codex/skills`、`~/.workbuddy/skills`。
- **init 出来的项目如果哪天公开，复制进去的 tong-* skill 也会跟着公开。** 公开前先删掉 `.agents/skills/tong-*`，或确认许可允许。
- 内容/视频套装不进默认同步。

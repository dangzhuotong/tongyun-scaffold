# 配套开发技能（项目级 skill）

做法参考 [deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)：项目用的 skill 当源码提交在项目里的 `.agents/skills/<名字>/SKILL.md`，各家 Agent 通过软链读同一份，`AGENTS.md` 在用到的步骤里直接点名。

## 两个版本：lite（默认）和 pro

Coding 套装 7 个工种（project / product / ui-design / api / test / code-review / deploy）有两个版本，init 和同步时二选一：

| 版本 | skill 名 | 来源 | 许可 | 需要权限 |
| --- | --- | --- | --- | --- |
| **lite**（默认） | `tong-project`、`tong-product`、`tong-ui-design`、`tong-api`、`tong-test`、`tong-code-review`、`tong-deploy` | 开源仓（仓名待定，默认地址 `https://github.com/dangzhuotong/tongyun-skills-lite.git` 为占位） | MIT | 不需要 |
| **pro** | 同名加 `-pro` | 私有仓 tongyun-skills-plus | 商业许可 | 需要 SSH 访问私有仓 |

选版本：

```bash
bash scripts/init-project.sh --edition pro <名> <用途> <目录>   # init 时选
TONGYUN_SKILLS_EDITION=pro bash scripts/init-project.sh ...      # 同上，用环境变量
bash scripts/sync-skills.sh --edition lite                       # 已有项目里切换
```

`sync-skills.sh` 的版本顺序：`--edition` → `TONGYUN_SKILLS_EDITION` → 上次同步记在 `SOURCES.md` 的版本 → `lite`。加版本开关之前同步过的项目会被识别成 pro，重跑不会被悄悄换成 lite。

切换版本时脚本会：复制新版本的 7 个目录、删掉另一版本的 7 个目录、重写 `SOURCES.md`，并把 `AGENTS.md` 里点名的 skill 链接改成新名字（只改这 7 个链接）。项目自己的 skill 不动。

## 本仓（公开）只放脚本，不放 skill 正文

两个版本的正文都不进脚手架。脚手架只提供：

- `scripts/init-project.sh`：初始化新项目，并调用同步脚本；
- `scripts/sync-skills.sh`：把选定版本的 7 个 skill 复制进**新项目**的 `.agents/skills/`。

`sync-skills.sh` 拒绝对脚手架仓本身运行；`init-project.sh` 也不允许初始化到脚手架目录。本仓 `.gitignore` 忽略 `.agents/skills/`，selftest 会检查仓里没有 `SKILL.md`。

## init 出来的项目长这样

```text
AGENTS.md                   # 各步骤点名对应 skill
CLAUDE.md -> AGENTS.md
.agents/skills/tong-*/      # 真实文件，随项目提交（lite：tong-xxx；pro：tong-xxx-pro）
.agents/skills/SOURCES.md   # edition + 来源仓 + commit SHA
.agents/notes/{proposed,implemented,rejected,archived}/
.claude/skills -> ../.agents/skills
.cursor/skills -> ../.agents/skills
scripts/sync-skills.sh
docs/...
```

## skill 来源

lite：

1. `TONGYUN_SKILLS_LITE=/path/to/lite-repo`（设置了就只用它，本地测试用）
2. `~/.cache/tongyun-skills-lite`（存在则 `git pull --ff-only`）
3. 否则 `git clone` `TONGYUN_SKILLS_LITE_GIT`（默认占位地址，开源仓建好后改成正式地址）到上面的缓存（缓存位置可用 `TONGYUN_SKILLS_LITE_CACHE` 改）

pro：

1. `TONGYUN_SKILLS_PLUS=/path/to/tongyun-skills-plus`
2. `~/.cache/tongyun-skills-plus`（存在则 `git pull --ff-only`）
3. 否则 `git clone git@github.com:dangzhuotong/tongyun-skills-plus.git` 到上面的缓存（可用 `TONGYUN_SKILLS_PLUS_GIT` / `TONGYUN_SKILLS_CACHE` 改）

拿不到来源仓时 init 照常完成，只打印警告，之后在项目里补跑 `bash scripts/sync-skills.sh`。

复制时整目录带上 `references/`、`examples/`、`assets/`、`agents/`，去掉 `tests/`、`__pycache__`、`*.log`/`*.tmp` 等；软链会被展开成真实文件。

## 更新

在项目根目录重跑 `bash scripts/sync-skills.sh`：原地覆盖当前版本的 `tong-*`、重写 `SOURCES.md`。项目自己的 skill 用 `<项目名>-xxx` 命名放在同一目录，不会被动。

## 注意

- 这些 skill 是项目级的，不要装进本机全局 `~/.cursor/skills`、`~/.codex/skills`、`~/.workbuddy/skills`。
- **用 pro 版的项目如果哪天公开，复制进去的 tong-*-pro 正文也会跟着公开。** 公开前先 `bash scripts/sync-skills.sh --edition lite` 切回开源版。lite 版是 MIT，公开没问题。
- 内容/视频套装不进默认同步。

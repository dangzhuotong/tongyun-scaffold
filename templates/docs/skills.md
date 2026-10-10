# 项目 skill

本项目的 agent skill 是**项目级文件**，跟代码一起提交，谁 clone 下来都能直接用。

## 目录

```text
.agents/skills/
  tong-project-pro/  tong-product-pro/  tong-ui-design-pro/  tong-api-pro/
  tong-test-pro/     tong-code-review-pro/  tong-deploy-pro/     # Coding 套装（同步来的）
  <项目名>-xxx/                                                  # 本项目自己的 skill
  SOURCES.md                                                     # 来源仓 + commit SHA
.claude/skills -> ../.agents/skills    # Claude Code
.cursor/skills -> ../.agents/skills    # Cursor（Codex 直接读 .agents/skills）
CLAUDE.md -> AGENTS.md
.agents/notes/{proposed,implemented,rejected,archived}/        # 设计记录
```

什么时候用哪个 skill，写在 [AGENTS.md](../AGENTS.md) 对应步骤里，不在这里另列一张表。

## 同步 Coding 套装

`tong-*` 来自私有仓 tongyun-skills-plus 的 `skills/`，复制成真实文件（不是软链）：

```bash
bash scripts/sync-skills.sh
```

- 来源顺序：环境变量 `TONGYUN_SKILLS_PLUS`（本地路径）→ `~/.cache/tongyun-skills-plus`（`git pull --ff-only`）→ SSH clone 到该缓存。
- 重跑即原地更新，并重写 `.agents/skills/SOURCES.md`；`tong-*` 的本地改动会被覆盖，项目自己的 skill 不受影响。
- 只写本项目 `.agents/skills/`，不碰 `~/.cursor`、`~/.codex`、`~/.workbuddy` 等全局目录。
- 更新后看一眼 `git diff .agents/skills` 再提交。

## 注意

- `.agents/skills` 不能写进 `.gitignore`，它就是要提交的。
- tong-* 来自私有、商业许可的 tongyun-skills-plus。**本项目若改成公开，这些 skill 正文也会跟着公开**；公开前先删掉 `.agents/skills/tong-*` 和 `SOURCES.md`，或确认许可允许。

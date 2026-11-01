# 项目级 Tongyun Coding 技能

技能是生成项目中的真实文件，来源为商业许可仓 `dangzhuotong/tongyun-skills`。脚手架只存模板与同步脚本，不存技能正文。技能使用与分发遵循来源许可，不能因脚手架是 MIT 就视为开源；项目公开前核对授权。

## 现行目录

```text
.agents/skills/
  tongyun-product/        # 项目规范：jobs/project/JOB.md
  tongyun-ui-design/
  tongyun-api/
  tongyun-test/
  tongyun-code-review/
  tongyun-deploy/
  tongyun-mac-ship/
  <项目名>-xxx/           # 自定义技能，脚本不管理
  SOURCES.md              # edition: tongyun、来源、HEAD、目录 commit 和 dirty 标记
.claude/skills -> ../.agents/skills
.cursor/skills -> ../.agents/skills
CLAUDE.md -> AGENTS.md
```

用哪个工种由项目 `AGENTS.md` 对应步骤点名。原 project 工种并入 `tongyun-product/jobs/project/JOB.md`，Mac 应用安装验收使用 `tongyun-mac-ship`。

## 来源与刷新

```bash
TONGYUN_SKILLS=/path/to/tongyun-skills bash scripts/sync-skills.sh
# 已配置来源或可访问仓库时：
bash scripts/sync-skills.sh
```

来源顺序：`TONGYUN_SKILLS`（设置则只用此 checkout）→ `TONGYUN_SKILLS_CACHE`（默认 `~/.cache/tongyun-skills`）→ clone `TONGYUN_SKILLS_GIT`（默认 `https://github.com/dangzhuotong/tongyun-skills.git`）。现有缓存只快进更新，失败则警告并尝试沿用本地版本。

完整校验七个 `SKILL.md` 与项目规范 `JOB.md` 后才写目标；整目录复制，包含 jobs、references、examples、assets、agents，展开软链并排除测试和临时文件。来源不完整时保留目标旧技能、规则和来源记录。init 在同步失败时保留骨架并警告，单独同步返回非零。

重跑覆盖七个套装目录，保留其他技能；本地改动会覆盖，请用项目自己的技能记录特有规则。不要忽略 `.agents/skills/`。不写全局 Agent 安装目录，已存在的真实客户端 skills 目录保留并提示。

## 旧项目迁移

1. 审阅并把新版 `scripts/sync-skills.sh` 复制到目标项目；默认重跑 init 会跳过已有脚本，不会悄悄覆盖它。
2. 指定现行来源后运行同步。旧 `--edition pro` / `--edition=pro`、`TONGYUN_SKILLS_PLUS` 和 `TONGYUN_SKILLS_PLUS_GIT` 兼容；新变量优先。现行 `--edition tongyun` 可省略。
3. 成功复制后，清理原七个 `tong-*` / `tong-*-pro` 精确目录，迁移根 `AGENTS.md` 中对应 Markdown 链接。project 链接改为 product 下的 JOB；其他正文、相近名字和自定义技能保留。
4. 审阅 `.agents/skills`、`AGENTS.md` 和来源记录的差异；其他历史文档若手写旧链接，按业务内容人工核对。

旧 `SOURCES.md` 的 lite/pro 值不再决定安装目录。显式传入 `--edition lite` 或设置 `TONGYUN_SKILLS_EDITION=lite` 会退出并解释商业许可，不能静默把 lite 换成商业套装。旧 lite 来源变量不再使用。

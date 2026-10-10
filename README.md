# tongyun-scaffold

Tong 系列**新项目初始化脚手架**（公开）。新开一个软件仓时，用它带上 AI 协作规则、轻量 DDD 目录约定和文档骨架，而不是把所有东西堆进 skills 仓。

- 技能包仍放在 [tongyun-skills-plus](https://github.com/dangzhuotong/tongyun-skills-plus)（可安装的工种）
- 本仓只负责：**项目怎么起步、Agent 先读什么、领域边界怎么画**

## 一分钟初始化

```bash
git clone https://github.com/dangzhuotong/tongyun-scaffold.git ~/tongyun-scaffold
bash ~/tongyun-scaffold/scripts/init-project.sh "my-app" "一句话说明这个项目做什么" ~/code/my-app
cd ~/code/my-app && git init && git add -A && git commit -m "init from tongyun-scaffold"
```

`bash scripts/selftest.sh` 自检。

`init-project.sh` 会写入：`AGENTS.md`（`CLAUDE.md` 软链到它）、`docs/*` 骨架、`.agents/notes/`、`.agents/skills/`（Coding 套装 7 个 skill 的真实文件）、`.claude/skills` / `.cursor/skills` 软链、`scripts/sync-skills.sh`、`.gitignore` 建议项；**不会**替你选技术栈或装依赖。不要初始化到脚手架目录本身。

## 轻量 DDD（给 Agent 用）

不全套战术模式。只约定三件事：

1. **限界上下文**：一个目录 ≈ 一块业务能力，跨上下文只走明确接口。
2. **聚合入口**：写操作从一个应用入口进去。
3. **改哪先读哪**：根 `AGENTS.md` 写总入口；上下文可有自己的 `AGENTS.md`。

细节见 [docs/architecture.md](docs/architecture.md)。


## 配套开发技能

照 [deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) 的做法：skill 是**项目文件**，放 `.agents/skills/<名字>/SKILL.md` 随项目提交，`AGENTS.md` 在对应步骤里点名。详见 [docs/skills.md](docs/skills.md)。

- init 时把 tongyun-skills-plus 的 Coding 套装（project / product / ui-design / api / test / code-review / deploy）**复制**进新项目，来源 commit 记在 `.agents/skills/SOURCES.md`。
- 本仓是公开的，**只放脚本，不放 skill 正文**（skills-plus 私有、商业许可）。
- 拿不到 skills-plus（没 SSH 权限 / 离线）时 init 照常完成并给出警告，之后在项目里补跑：

```bash
bash scripts/sync-skills.sh   # 重跑即原地更新
```

- 不装进本机全局 `~/.cursor/skills` 等目录。
- ⚠️ init 出来的项目如果公开，里面的 tong-* skill 也会跟着公开。

## 许可

MIT。欢迎 fork；不要把真实密钥、客户数据写进模板。

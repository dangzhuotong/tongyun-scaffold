# tongyun-scaffold

Tong 系列**新项目初始化脚手架**（公开）。新开一个软件仓时，用它带上 AI 协作规则、轻量 DDD 目录约定和文档骨架，而不是把所有东西堆进 skills 仓。

- 技能包放在单独的仓：开源 lite 版（MIT，仓名待定）和商业 pro 版 tongyun-skills-plus（私有）
- 本仓只负责：**项目怎么起步、Agent 先读什么、领域边界怎么画**

## 一分钟初始化

```bash
# 1. 克隆脚手架
git clone https://github.com/example-org/tongyun-scaffold.git ~/tongyun-scaffold

# 2. 初始化新项目（参数：<项目名> <用途说明> <目标目录>）
bash ~/tongyun-scaffold/scripts/init-project.sh "fictional-app" "虚构示例系统" ~/projects/fictional-app

# 3. 进入新项目并建立版本库
cd ~/projects/fictional-app
git init && git add -A && git commit -m "init from tongyun-scaffold"
```

初始化脚本会在目标目录生成完整项目骨架：
- **协作规范**：`AGENTS.md`（`CLAUDE.md` 软链至此）与 `.agents/skills/`（预置 7 个开发 skill，软链至 `.claude/skills`、`.cursor/skills`）。
- **文档骨架**：`docs/` 结构（需求 PRD、轻量 DDD 架构、命令表与 `docs/design/ui-guard.md` 界面守则清单）。
- **设计决策笔记**：`.agents/notes/`（按 `proposed`、`implemented`、`rejected`、`archived` 分类管理）。
- **同步工具**：`scripts/sync-skills.sh` 与基础 `.gitignore`。

> **说明**：
> - 脚本仅创建结构规范，不绑定技术栈或安装运行时依赖。
> - 请勿将脚手架仓库自身作为目标目录。
> - 在脚手架根目录可运行 `bash scripts/selftest.sh` 进行模板完整性自检。

## 轻量 DDD（给 Agent 用）

不全套战术模式。只约定三件事：

1. **限界上下文**：一个目录 ≈ 一块业务能力，跨上下文只走明确接口。
2. **聚合入口**：写操作从一个应用入口进去。
3. **改哪先读哪**：根 `AGENTS.md` 写总入口；上下文可有自己的 `AGENTS.md`。

细节见 [docs/architecture.md](docs/architecture.md)。


## 配套开发技能

照 [deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) 的做法：skill 是**项目文件**，放 `.agents/skills/<名字>/SKILL.md` 随项目提交，`AGENTS.md` 在对应步骤里点名。详见 [docs/skills.md](docs/skills.md)。

- init 时把 Coding 套装 7 个工种（project / product / ui-design / api / test / code-review / deploy）**复制**进新项目，来源 commit 记在 `.agents/skills/SOURCES.md`。
- 两个版本可选：**lite**（默认，开源 MIT 精简版 `tong-xxx`，不需要任何权限）和 **pro**（商业完整版 `tong-xxx-pro`，来自私有 tongyun-skills-plus）。

```bash
bash scripts/init-project.sh <名> <用途> <目录>                  # 默认 lite
bash scripts/init-project.sh --edition pro <名> <用途> <目录>    # 用 pro（需私有仓权限）
bash scripts/sync-skills.sh --edition lite                       # 在项目里切换 / 重跑即原地更新
```

- 本仓是公开的，**只放脚本，不放任何版本的 skill 正文**。
- 拿不到来源仓（离线 / 没权限）时 init 照常完成并给出警告，之后在项目里补跑 `bash scripts/sync-skills.sh`。
- 不装进本机全局 `~/.cursor/skills` 等目录。
- ⚠️ 用 pro 版的项目如果公开，里面的 tong-*-pro 也会跟着公开；公开前先切回 lite。

## 许可

MIT。欢迎 fork；不要把真实密钥、客户数据写进模板。

界面守则清单与 `.agents/notes/` 按状态分目录的做法，思路参考 [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)（MIT），按通用项目重写。

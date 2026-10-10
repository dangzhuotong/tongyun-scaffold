# tongyun-scaffold

Tong 系列**新项目初始化脚手架**（公开）。新开一个软件仓时，用它带上 AI 协作规则、轻量 DDD 目录约定和文档骨架，而不是把所有东西堆进 skills 仓。

- 技能包仍放在 [tongyun-skills-plus](https://github.com/dangzhuotong/tongyun-skills-plus)（可安装的工种）
- 本仓只负责：**项目怎么起步、Agent 先读什么、领域边界怎么画**

## 一分钟初始化

```bash
git clone https://github.com/dangzhuotong/tongyun-scaffold.git my-app
cd my-app
bash scripts/init-project.sh "my-app" "一句话说明这个项目做什么"
# 然后改 remote 指向你的新仓
```

`init-project.sh` 会写入：`AGENTS.md`、`docs/*` 骨架、`.gitignore` 建议项；**不会**替你选技术栈或装依赖。

## 轻量 DDD（给 Agent 用）

不全套战术模式。只约定三件事：

1. **限界上下文**：一个目录 ≈ 一块业务能力，跨上下文只走明确接口。
2. **聚合入口**：写操作从一个应用入口进去。
3. **改哪先读哪**：根 `AGENTS.md` 写总入口；上下文可有自己的 `AGENTS.md`。

细节见 [docs/architecture.md](docs/architecture.md)。

## 许可

MIT。欢迎 fork；不要把真实密钥、客户数据写进模板。

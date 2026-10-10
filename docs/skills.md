# 配套开发技能（Coding 套装）

脚手架只管「项目怎么起步」；真正干活的工种在 [tongyun-skills-plus](https://github.com/dangzhuotong/tongyun-skills-plus) 的 **coding** 套装。

**这些是项目级 skill**：装进仓库自己的 `.cursor/skills` / `.agents/skills`，不要灌到本机 `~/.cursor/skills` 全局目录（工作机、个人全局配置分开）。

| 任务 | 技能 | 交给它 | 期望拿回 |
| --- | --- | --- | --- |
| 建/改 AGENTS、工种路由 | `tong-project-pro` | 项目目标、现有文档 | 更新后的规则与检查入口 |
| 需求、验收 | `tong-product-pro` | 用户目标、现有 R-xx | 保留编号的需求与验收 |
| Web 界面 | `tong-ui-design-pro` | 需求编号、设计约束 | 实现与对照说明 |
| 后端 API / 迁移 | `tong-api-pro` | 需求与数据约束 | 接口、权限、迁移 |
| 测试验收 | `tong-test-pro` | AT 用例、环境 | 实际结果与缺陷 |
| 代码审查 | `tong-code-review-pro` | PR / diff | 带定位的问题清单 |
| 部署运维 | `tong-deploy-pro` | 已授权发布范围 | 健康证据 / 回滚说明 |

源文件：`tongyun-skills-plus/skills/tong-*-pro/`。套装说明：`bundles/coding/README.md`。

## 安装（项目内）

在**已 init 或本脚手架 clone 出来的项目根目录**：

```bash
bash scripts/install-coding-skills.sh
```

默认链到本仓：

- `.cursor/skills/<name>`
- `.agents/skills/<name>`

环境变量：

- `TONGYUN_SKILLS_PLUS`：已有 skills-plus 本地路径时优先用
- `TONGYUN_SKILLS_TARGETS`：自定义目标目录（仍建议只写项目内路径）

装完后**在打开该仓库的 Agent 对话**里用 `$tong-project-pro` 等。登记 ≠ 已验证部署依赖。

## 和脚手架的关系

1. `init-project.sh` → 空仓文档与 AGENTS  
2. `install-coding-skills.sh` → **本项目**挂上 7 个开发工种  
3. 用 `$tong-project-pro` 按任务微调本仓 `docs/skills.md` / `AGENTS.md`

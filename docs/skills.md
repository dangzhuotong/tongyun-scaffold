# 配套开发技能（Coding 套装）

脚手架只管「项目怎么起步」；真正干活的工种在 [tongyun-skills-plus](https://github.com/dangzhuotong/tongyun-skills-plus) 的 **coding** 套装。

| 任务 | 技能 | 交给它 | 期望拿回 |
| --- | --- | --- | --- |
| 建/改 AGENTS、工种路由 | `tong-project-pro` | 项目目标、现有文档 | 更新后的规则与检查入口 |
| 需求、验收 | `tong-product-pro` | 用户目标、现有 R-xx | 保留编号的需求与验收 |
| Web 界面 | `tong-ui-design-pro` | 需求编号、设计约束 | 实现与对照说明 |
| 后端 API / 迁移 | `tong-api-pro` | 需求与数据约束 | 接口、权限、迁移 |
| 测试验收 | `tong-test-pro` | AT 用例、环境 | 实际结果与缺陷 |
| 代码审查 | `tong-code-review-pro` | PR / diff | 带定位的问题清单 |
| 部署运维 | `tong-deploy-pro` | 已授权发布范围 | 健康证据 / 回滚说明 |

源文件目录：`tongyun-skills-plus/skills/tong-*-pro/`。套装说明：`bundles/coding/README.md`。

## 安装（本机 Agent）

在已 clone 的本仓根目录：

```bash
# 需要能拉私有仓 dangzhuotong/tongyun-skills-plus（或设置 TONGYUN_SKILLS_PLUS）
bash scripts/install-coding-skills.sh
```

默认链到：

- `~/.cursor/skills/<name>`
- `~/.workbuddy/skills/<name>`（若目录存在）
- `~/.codex/skills/<name>`（若目录存在）

环境变量：

- `TONGYUN_SKILLS_PLUS`：skills-plus 本地路径（已有 clone 时优先用）
- `TONGYUN_SKILLS_TARGETS`：空格分隔的目标 skills 根目录

装完在 Cursor / WorkBuddy / Codex 重开对话。登记 ≠ 已验证依赖（如部署还要云账号）。

## 和脚手架的关系

1. `init-project.sh` → 空仓文档与 AGENTS  
2. `install-coding-skills.sh` → 本机装上 7 个开发工种  
3. 用 `$tong-project-pro` 按项目任务微调路由表（改本仓 `docs/skills.md` / `AGENTS.md`）

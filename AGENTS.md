# tongyun-scaffold · AI 开发规则

所有在本仓库工作的 agent 先读本文件。细节链接到各自唯一维护的文档，不要在多处复制命令表。

## 项目与修改入口

- 用途：Tong 系列项目初始化脚手架（公开模板）
- 技术栈：未建立（初始化后由人补齐；不要假装已有脚手架）
- 轻量 DDD：限界上下文与目录见 [docs/architecture.md](docs/architecture.md)。跨上下文不要直接改对方的持久化或内部类型。

| 要改什么 | 先读 |
| --- | --- |
| 需求、验收 | [docs/prd.md](docs/prd.md) |
| 排期 | [docs/plan.md](docs/plan.md) |
| 模块边界 | [docs/architecture.md](docs/architecture.md) |
| 命令、CI | [docs/development.md](docs/development.md) |
| 主流程 | [docs/user-flows.md](docs/user-flows.md) |
| 测试 | [docs/testing/acceptance-tests.md](docs/testing/acceptance-tests.md) |
| 长期决定 | [docs/decisions/](docs/decisions/) |

## 开发与验证

- 命令表只在 [docs/development.md](docs/development.md) 维护。未建立的入口标「未建立」，**不要声称跑过不存在的命令**。
- 改动前读受影响上下文的规则和实现，写清目标行为与验收方式。
- 交接写清：改了什么、实际跑了哪些检查、失败/跳过/未运行、下一步。

## 配套技能

开发默认用 Coding 套装，清单与安装见 [docs/skills.md](docs/skills.md)。执行前读取该技能真实 `SKILL.md`。登记 ≠ 已安装。

| 任务 | 技能 | 状态 |
| --- | --- | --- |
| 项目规范 / 工种路由 | tong-project-pro | 见 install-coding-skills.sh |
| 需求 / 验收 | tong-product-pro | 同上 |
| Web 界面 | tong-ui-design-pro | 同上 |
| 后端 API / 迁移 | tong-api-pro | 同上 |
| 测试 | tong-test-pro | 同上 |
| 代码审查 | tong-code-review-pro | 同上 |
| 部署运维 | tong-deploy-pro | 同上（需授权） |


## 修改约束

- 沿用现有技术栈与目录；保护工作区已有改动。
- 密钥、Token、客户数据：**不进仓、不打印**。

## 完成交接

说明改动、检查结果、缺口与下一步。提交 / 推送 / 发版仅在用户明确要求时做。

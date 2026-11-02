# 开发与命令

脚手架为 Bash 脚本和文档模板，不运行常驻服务。

| 任务 | 命令 | 成功条件 |
| --- | --- | --- |
| 全套回归 | `bash scripts/selftest.sh` | 退出 0，末尾 selftest ok |
| 初始化专项 | `bash tests/test_init_project.sh` | 退出 0 |
| 同步专项 | `bash tests/test_sync_skills.sh` | 退出 0 |
| 静态检查 | `shellcheck scripts/*.sh` | 退出 0（需安装 ShellCheck） |

生成项目的技术栈和运行命令由各项目维护，模板中保留「未建立」。

UI 资产生成：`node design-system/scripts/build-tokens.mjs`；一致性与合同检查：`node design-system/scripts/build-tokens.mjs --check && node design-system/tests/contracts.mjs`。示例是可直接打开的静态文件，不需启动服务。React/Vue 编译须在有对应依赖的消费项目执行。

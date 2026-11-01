# 产品需求

Tongyun 系列项目初始化脚手架；复用现有模板、同步与 CI，修正技能源和命名，不重建调度或业务框架。

| ID | 需求 | 验收 |
| --- | --- | --- |
| R-01 | 初始化与同步采用现行 tongyun-skills Coding 套装 | 七个现行目录，project 并入 product JOB，含 mac-ship |
| R-02 | 旧项目可迁移且保护自定义内容 | pro 参数和来源变量兼容；精确迁移旧链接及目录，重复同步幂等 |
| R-03 | 不混淆许可或伪装成功 | lite 明确拒绝；来源缺失则警告/失败，旧目标保持；不向脚手架或全局安装正文 |

验收见 [testing/acceptance-tests.md](testing/acceptance-tests.md)。Superpowers 安装和工作台调度改造不在此次命名迁移范围。

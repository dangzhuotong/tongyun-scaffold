# 架构（轻量 DDD）

状态：脚手架资产边界现行；以下 src/ 为生成项目的结构建议。

## 原则

1. **一个限界上下文一个目录**（或一个清晰的包前缀）。名字用业务语言。
2. **写操作走应用入口**（command / use-case / application service），基础设施藏在适配器后。
3. **跨上下文只依赖接口或事件**，禁止深层 import 对方内部模块。
4. Agent 改代码：先定位上下文 → 读该目录规则（若有）→ 只在边界内改。

## 建议目录

```
src/
  <context-a>/
    domain/
    application/
    adapter/
  <context-b>/
  shared/
```

空项目可先只建 `docs/` 与根 `AGENTS.md`，第一个功能落地时再切出第一个上下文。

## 当前上下文一览

| 上下文 | 目录 | 职责 | 对外接口 |
| --- | --- | --- | --- |
| 项目初始化 | scripts/、templates/ | 生成项目规则和可选 UI 资产 | init-project.sh --ui |
| UI 设计资产 | design-system/ | tokens、基础组件、页面模式与验收 | README.md、tokens.json、adapters/ |
| 技能分发适配 | scripts/sync-skills.sh | 从独立许可来源同步技能 | sync-skills.sh |

UI 集成取舍见 [ADR](decisions/0002-ui-assets.md)。产品业务与框架运行时属于消费项目，不进入共享设计资产。

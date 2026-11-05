# ADR：在初始化仓库内维护轻量 UI 资产

状态：现行 · 2026-11-02

目标：新项目获得可读的设计规范、tokens、基础组件和页面模式；现有手帐保留经过使用的 UI。初始化器目前是 Bash + 文档模板，不是 React/Vue 应用；手帐是 React 19 / Tailwind 4 / Tauri 2，无通用组件库依赖。

- `design-system/`：公开 MIT 源码资产，无运行时依赖。tokens、CSS、React 包装、Vue 按钮、shadcn 变量桥接、演示与验收合同共同版本化。
- `templates/DESIGN.md`：生成项目的设计入口；`scripts/init-project.sh --ui` 是唯一复制入口。资产进入 `ui/`，由消费项目按自身目录引入，不替它创建框架应用。
- `scripts/sync-skills.sh`：沿用七个 Coding Skills 的来源、许可、版本追踪和客户端软链；`tongyun-ui-design` 引用共享资产。Skill 正文继续由独立技能库维护，不在本公开仓建立另一份。
- `design-system/adapters/`：技术栈边界。React 优先 shadcn/ui，Vue 优先 shadcn-vue；仅复杂交互需要时按项目版本添加，原生 Button/Input/Card 足够时不引库。此仓的颜色桥接不承诺整个 shadcn registry 已经安装或验收。
- `design-system/docs/apple-platforms.md`：平台边界。未来 SwiftUI/UIKit/AppKit 原生导航交给系统；WebView/CSS 不冒充 Liquid Glass。正文、卡片、表格保持实色。

不创建独立组件产品、私有 npm 包或新远程仓库，不迁移手帐源码。默认不覆盖已有 ui 整组资产，避免版本混装；升级审阅整组差异。基础组件和主题 API 仍为 0.1 试用接口。

验收：完整 selftest、生成物一致性、对比度、初始化保护、真实技能同步；React/Vue 有对应依赖时编译；浏览器检查示例四主题、窄屏和失败恢复。原生设备与消费项目未执行的项目明确保留。

# Tongyun 共享 UI 资产约定

本仓是初始化脚手架，不是应用。设计资产唯一入口为 [design-system](design-system/README.md)，tokens/tokens.json 是数值来源，生成 CSS 不手工编辑。版本 0.1.0。

以橦云手帐 React 19 / Tailwind 4 / Tauri 2 的暖纸、抹茶绿、轻影为 paper 基准，独立保留 paper-dark；desktop/cloud 用于适合的新产品。现有产品自己的 DESIGN.md、组件和用户主题优先，新组件不推动手帐重绘。来源与增强值见 [基线](design-system/docs/baseline.md)。

新共享组件字重 400/500，控件 8px、卡片 12px、面板 20px；语义颜色切换主题，内容保持实色。复杂交互采用消费项目成熟组件的无障碍行为，React 选择 shadcn/ui，Vue 选择 shadcn-vue；已有库优先，不在脚手架安装框架运行时。

Agent UI Skill 通过既有 sync-skills 取得，公开仓不复制商业正文。初始化显式 --ui，默认 none；不自动更改应用入口。Web 半透明只用于用户开启的局部导航，Apple 材质是未来原生适配层。

发布必须运行 [命令表](docs/development.md) 中的回归，并按 [验收清单](design-system/docs/acceptance.md) 分开记录浏览器、编译和原生设备证据。

## 工作台组合基准

视觉交付必须先看真实场景，不能用测试台代替产品模板。当前样本是 examples/index.html：侧栏 → 标题及唯一主操作 → 概览条 → 今日行动/本周节奏 + 专注/随记。组合样式在 patterns/workspace.css，按 workspace 根作用域启用。主内容字号 12–15px，辅助信息 10–11px，微标签 8–9px 只用于不影响操作的次要说明；新消费项目按实际设备阅读距离复验。

参考 shadcn Dashboard 的操作分组、表面层级，Tasks 的筛选和任务行密度；保留手帐暖纸与抹茶绿。页面组合参考设计关系；Input/Button 使用共享 CSS，Select 使用 React + Radix，不宣称已经安装完整 shadcn registry。效果验收须检查同一视口画面、主题切换后的稳定状态及主要交互，不能以编译通过代替视觉判断。

## 表单控件

Input、Button、Select 默认高度 36px、圆角 8px，输入字号 14px、标签 13–14px。参考当前 shadcn Input/Select 的轻边框、单层焦点环和菜单密度；颜色沿用 Tongyun 主题。默认边框使用 input-border，focus 使用 control-border 加一层 3px 柔和环，增强对比模式恢复强边界。轻边框本身不作为独立 3:1 边界合格证明，消费项目仍需按实际表面验收。

复杂 Select 使用 adapters/select.tsx 的 Radix 交互，不能再手写菜单键盘状态机。预览也使用相同适配器；表单在 native dialog 内时 Portal 必须留在该 dialog 中，同时继承主题。关闭、焦点返回、原生表单值、reset、disabled 和主题同步都要验证。

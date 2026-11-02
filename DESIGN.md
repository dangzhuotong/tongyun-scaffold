# Tongyun 共享 UI 资产约定

本仓是初始化脚手架，不是应用。设计资产唯一入口为 [design-system](design-system/README.md)，tokens/tokens.json 是数值来源，生成 CSS 不手工编辑。版本 0.1.0。

以橦云手帐 React 19 / Tailwind 4 / Tauri 2 的暖纸、抹茶绿、轻影为 paper 基准，独立保留 paper-dark；desktop/cloud 用于适合的新产品。现有产品自己的 DESIGN.md、组件和用户主题优先，新组件不推动手帐重绘。来源与增强值见 [基线](design-system/docs/baseline.md)。

新共享组件字重 400/500，控件 8px、卡片 12px、面板 20px；语义颜色切换主题，内容保持实色。复杂交互采用消费项目成熟组件的无障碍行为，React 选择 shadcn/ui，Vue 选择 shadcn-vue；已有库优先，不在脚手架安装框架运行时。

Agent UI Skill 通过既有 sync-skills 取得，公开仓不复制商业正文。初始化显式 --ui，默认 none；不自动更改应用入口。Web 半透明只用于用户开启的局部导航，Apple 材质是未来原生适配层。

发布必须运行 [命令表](docs/development.md) 中的回归，并按 [验收清单](design-system/docs/acceptance.md) 分开记录浏览器、编译和原生设备证据。

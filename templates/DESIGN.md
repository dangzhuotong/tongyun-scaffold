# 项目界面约定 · Tongyun UI 0.1

初始主题：`{{UI_THEME}}`。资产与接入说明见 [ui/README.md](ui/README.md)，原始令牌在 [tokens.json](ui/tokens/tokens.json)，不要直接改生成的 CSS。

仅在新增 UI 根节点启用 `ty-root`、`data-ty-theme="{{UI_THEME}}"` 和 `data-ty-material="solid"`。主题是初始化选择，不代表未来只能使用一种；切换时使用完整语义层。已有项目以实际界面为准，不能以接入为由统一重绘。

复用现有库和控件；复杂交互交给已选成熟库。新项目 React 可用 adapters/react.tsx，Vue 可用 adapters/Button.vue；没有安装的库不宣称可用。浮层继承主题，输入失败保留内容。页面模式见 [patterns](ui/patterns/README.md)，验收见 [清单](ui/docs/acceptance.md)。

Apple 原生导航和控制优先系统外观，Web 默认实色，材质策略见 [平台策略](ui/docs/apple-platforms.md)。不为卡片、表格和正文全局添加模糊。

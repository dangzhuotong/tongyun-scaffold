# 组件行为与主题适配

| 场景 | v0.1 选择 | 接入者责任 |
| --- | --- | --- |
| 按钮、输入、卡片 | 原生 HTML + ty 类；React 包装、Vue 按钮 | 标签、提交、错误、busy 状态由应用提供 |
| Dialog / Select / Tooltip | 已装成熟库优先；示例用 HTML dialog/select | 焦点约束、Esc、焦点恢复、可访问名称、portal 主题 |
| 表格 | 原生 table + 横向滚动容器 | 排序、分页、虚拟化按业务需求接入，不用 CSS 模拟数据行为 |
| shadcn React / Vue | 语义变量映射 | 不自动安装 CLI；按项目 registry/版本核对变量；库自带渐变和 destructive 按钮逐项验收 |
| 原生 Apple | 系统导航和控制 | 不导入 Web CSS；见 Apple 策略 |

`--destructive` 是可读的错误文字色；v0.1 推荐 destructive 为文字/描边按钮。如库默认使用实心 destructive，应改成文字/描边样式或单独建立并验证 on-danger 色，不直接把 card 当作通用反白色。基础 ty-card 是 section，使用时提供标题或 aria-label；Field 支持外部帮助文本 aria-describedby 并追加错误。

shadcn 参考（2026-11-02 重新查证）：https://ui.shadcn.com/docs/theming 、https://www.shadcn-vue.com/docs/theming 。主题映射与组件行为分开维护，v0.1 不承诺所有库版本兼容。

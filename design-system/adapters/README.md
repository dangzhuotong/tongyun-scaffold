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

## 当前表单组件

Input/Field/Button 使用共享 CSS；Field 是 8px 间距的字段组，支持描述与错误关联。React Select 使用 `select.tsx`，消费项目安装 React、React DOM 与 `@radix-ui/react-select`；已用 shadcn 的项目保留自己的 Select，仅映射主题，不额外安装第二份。Vue 项目继续选择 shadcn-vue，本版没有自制 Vue Select。

Select 接收 label、options、value/onValueChange、disabled、invalid、describedBy 等；container 指向同主题 Portal 宿主，在 HTML dialog 内须传该 dialog。示例保留原生 select 作为未加载增强时的回退，并将值、reset、disabled、主题变更同步到 React 包装。

预览构建仅需隔离依赖目录，不在脚手架内安装 node_modules：

```bash
npm install --prefix /path/to/deps --ignore-scripts react@19.3.1 react-dom@19.3.1 @radix-ui/react-select@2.4.1 esbuild@0.28.2
node design-system/scripts/build-preview.mjs /path/to/deps
```

源码 `examples/select-preview.tsx`，离线构建物 `examples/select-preview.js`。第三方声明在 `examples/SELECT-NOTICES.txt`；react-remove-scroll-bar 的 npm 包未附许可文件，构建所需原文取自其上游 https://github.com/theKashey/react-remove-scroll-bar/blob/master/LICENSE ，保留于 scripts/licenses/。脚手架基础 CSS 无运行依赖；只有选用 React Select 或运行增强预览才使用该运行时。

实际参考：2026-11-02 阅读并操作 [shadcn Input](https://ui.shadcn.com/docs/components/input) 和 [shadcn Radix Select](https://ui.shadcn.com/docs/components/radix/select)。本适配器复用 Radix 行为，样式由 Tongyun CSS 表达，不声称复制完整 shadcn 组件集。

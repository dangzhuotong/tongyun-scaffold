# Tongyun UI Design System 0.1.0

轻量源码资产，随 tongyun-scaffold 维护，不发布私有 npm 包。CSS 按原始 palette → 语义角色 → 组件别名三层输出；颜色只有一份真相 `tokens/tokens.json`，生成 `tokens/tokens.css`；基础组件样式不依赖框架且通过 `.ty-root` 启用；可选 React Select 依赖 Radix，预览含离线构建运行时。手帐仅作为只读视觉来源，没有迁移它的业务代码。

## 接入

初始化：`bash scripts/init-project.sh --ui paper my-app "用途" /path/to/app`（在 scaffold 根目录）。`--ui paper|paper-dark|desktop|cloud|none` 默认 none；无 UI 项目不加资产。不自动安装组件库、不修改 package.json 或应用入口。

生成目录 `ui/`、根 `DESIGN.md`。在应用入口依次引入 `ui/tokens/tokens.css`、`ui/components/ui.css`；按框架调整相对路径。在根节点添加 `class="ty-root" data-ty-theme="paper" data-ty-material="solid"`，React 使用 className。主题由应用持久化，未设置属性不注入默认主题。Portal 必须位于同主题容器内，或给 portal 宿主同步主题和 ty-root，避免浮层丢失令牌。

- React 19：按需复制 `adapters/react.tsx` 的 Button、Field、Card；已有组件优先，不替换全站组件。
- React Select：按需使用 `adapters/select.tsx`，复用 Radix 的菜单行为，依赖与构建见 adapters/README.md。
- Vue 3：可直接复制 `adapters/Button.vue`；表单、卡片用语义 HTML + ty 类。
- 已用 shadcn/ui、shadcn-vue：额外引入 `adapters/shadcn.css`；保留库的 Dialog、Select、Tooltip 行为。只映射颜色，不声称覆盖库所有组件。旧 `hsl(var(--background))` 版本要升级映射，不能直接套此完整颜色变量。见 `adapters/README.md`。
- 其他库：只映射官方主题接口。没有现成库时先用原生控件，复杂交互再按技术栈选成熟无障碍 primitives；不强装第二套库。

## 主题与来源

`paper` 保留手帐暖纸 + #4D7C5D 抹茶绿，`paper-dark` 保留其 #121214 深色；`desktop` 为现行云芽暖炭黑，`cloud` 为云芽阅读浅色。手帐已有主题和字体选项继续存在，云芽不是迁移命令。基础数值来自实际源码，次级字色和输入边框作了可读性增强，不能宣称逐像素复刻。详见 [基线记录](docs/baseline.md)。

常规正文 15px、元信息 13px，新组件标题 500；手帐已有粗体不回改。卡片 12px、控件 8px，正文内容不铺模糊。禁用态可降低对比，不能用于正常说明。品牌标志的浅绿/桃橙保留标志身份，与手帐操作绿区分。

## 页面与验收

`examples/index.html` 可直接以 file URL 打开，无网络、无服务。包含完整今日工作台、任务筛选与勾选、创建弹窗、快捷搜索、详情侧栏、专注计时与随记。任务创建支持延迟和失败测试，成功后只写入当前页内存，刷新重置，不访问产品数据。外观与失败测试在设置中；工作台组合样式可复用 patterns/workspace.css。`patterns/README.md` 说明业务接入合同。运行 `node scripts/build-tokens.mjs --check` 校验生成物；`node tests/contracts.mjs` 检查对比度、引用和适配合同。浏览器手动验收见 [清单](docs/acceptance.md)。

Apple 采用策略见 [apple-platforms.md](docs/apple-platforms.md)。Web 的可选模糊不是系统 Liquid Glass，不根据 UA 自动打开。

## 版本与边界

tokens、CSS 类和适配器是 0.1 试用接口，更新通过审阅源码 diff；初始化默认整组跳过已有 ui/，避免用新文件补入旧版或自定义资产；DESIGN.md 独立保护。FORCE=1 显式覆盖当前发行文件，升级前需审阅差异并备份。后续升级建议整组比较后替换 ui，不能把新旧 tokens 与组件文件随意混合。未实现完整组件库、原生壳桥接或设计工具插件；见验收记录。资产随脚手架 MIT，商业 Agent Skill 由独立技能库分发。

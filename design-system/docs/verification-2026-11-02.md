# 0.1.0 验证记录 · 2026-11-02

本轮接续既有未提交草稿，在 canonical tongyun-scaffold 中完成集成；手帐仅只读检查。示例不访问产品数据，没有真实保存接口。

| 检查 | 实际结果与范围 |
| --- | --- |
| `/bin/bash scripts/selftest.sh` | 通过：现有初始化/技能同步回归及新增 UI 初始化测试，包含 none、四主题、无效参数、已有资产整组保护及 FORCE 显式覆盖 |
| `node design-system/scripts/build-tokens.mjs --check` | 通过：JSON 与生成 CSS 一致 |
| `node design-system/tests/contracts.mjs` | 通过：四主题 64 组正文/辅助/状态文字、8 组按钮、8 组控件边界对比度；示例本地资源引用 |
| 真实 Skill 初始化 | 指定已有 tongyun-skills checkout，七个 Coding Skills 同步成功，来源 HEAD c7451ca；生成根 DESIGN.md、ui/ 及 tongyun-ui-design 的 design-system-v01 引用；不向本公开仓复制技能正文 |
| React | 在临时消费目录使用 React 19.3.1、Typescript 6.0.3 strict/noEmit 编译适配器与消费示例；另用手帐现有 TypeScript 编译器复验通过；服务端渲染断言 busy/disabled/default type 和 Field 标签、帮助、错误关联通过 |
| Vue | 在临时消费目录使用 Vue 3.5.44、vue-tsc strict/noEmit 编译 Button.vue 与消费示例，通过；compiler-sfc 脚本与模板编译通过 |
| 浏览器布局 | ego-lite，静态 examples/index.html；paper、paper-dark、desktop、cloud × 1280/320 CSS px，均无整页横向溢出；200% CSS zoom 下无横向溢出（不等同所有浏览器原生缩放测试） |
| 浏览器交互 | dialog 自动聚焦输入，Esc 关闭后焦点返回触发按钮；Tab 可见焦点；必填为空时拦截并聚焦输入；模拟失败保留输入，取消失败后重试成功；列表 loading/empty/error/retry、详情返回均通过 |
| 材质与动效 | 默认实色；显式开启导航 blur 后，CDP 模拟减少透明/增强对比/forced-colors 时均为 none；模拟减少动效时按钮 transition 为 0s |
| 源码差异 | git diff --check 通过；未修改手帐业务、窗口配置或运行环境 |

框架依赖仅用于临时编译验证，没有加入脚手架运行时。未安装或验证完整 shadcn/ui、shadcn-vue registry，颜色桥接需消费项目按版本检查；没有原生 Apple 工程，因此原生编译、VoiceOver、Dynamic Type、系统版本降级和设备性能未验。ShellCheck 本机不可用，未运行；现有 CI 的 Linux ShellCheck 与 macOS/Linux 回归须查看远程结果。

本轮没有启动项目服务。手帐 1431 登记服务为 stopped 并保持原状。静态示例通过 file URL 检查，浏览器任务结束已关闭测试空间。截图另随本轮交付，不含手帐真实用户数据。

官方参考本轮重新阅读：[shadcn/ui 主题](https://ui.shadcn.com/docs/theming)、[shadcn-vue 主题](https://www.shadcn-vue.com/docs/theming)、[Apple Materials](https://developer.apple.com/design/human-interface-guidelines/materials)。使用语义变量桥接和把材质限制在导航/控制层，属于本设计系统据此作出的实施决定。

# 基础控件对齐 · 2026-11-02

范围：共享 Input/Field/Button/Checkbox 样式，新增 React/Radix Select，示例使用同一适配器。保留页面布局、纸感主题、初始化入口与手帐业务。

实际阅读并操作 shadcn 当前 Input 与 Radix Select 官方页。提取控件比例与状态：36px 默认高度、14px 输入字号、8px 圆角、轻边框、单层 3px 焦点环；没有复制整套 registry。Select 不再自行模拟菜单行为，交给 @radix-ui/react-select 2.4.1。预览运行时由 React/React DOM 19.3.1、esbuild 0.28.2 隔离构建，依赖和许可证见 adapters/README.md 与 examples/SELECT-NOTICES.txt。

主要变化：重边框和外扩黑色双线改为轻边框加单层柔和环；标签/字段/按钮统一尺寸；菜单加入真实选中标记、悬停、键盘导航和位置避让；Checkbox 与 busy 反馈对齐。组件样式在 components/ui.css，消费项目可直接复用，不仅是示例覆盖。

实际验证：

- React Select、Input/Field 及预览桥接严格 TypeScript 编译通过；预览依赖外置，没有给脚手架创建 node_modules。
- 真实浏览器验证菜单 Esc 不关闭表单、方向键/End/Enter 选择、菜单关闭后焦点返回；选中“成长”后创建任务标签为“成长”，表单 reset 后回到“工作”。
- 通过设置 Select 切换深色，及顶部按钮切回浅色时 trigger 同步。提交期间自定义 Select 禁用，失败后恢复可操作且输入保留。
- 焦点实测：Input 36px、14px、outline none、单层 3px box-shadow；四主题与窄屏、错误、禁用、减少动效与强制颜色按本轮检查记录执行。
- 本地完整 selftest、生成 CSS 一致性和合同检查通过。合同的 control-border 检查是强边界/焦点令牌，不把默认淡边框宣称为 3:1 合格。

初轮键盘自动测试在 Radix 异步焦点尚未返回时立即断言，出现夹具误报；改为等待实际焦点状态后验证通过，未改组件行为迎合测试。

交付仍是当前页内存演示，无后端、无生产写入、无项目服务启动。原生 Apple 和真实辅助技术实机测试未执行。本轮没有新建独立组件产品。

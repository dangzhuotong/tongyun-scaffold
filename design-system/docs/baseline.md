# 手帐基准核验

只读检查实际仓库 tongyun-planner（本轮检查工作树干净，未修改）。React 19.1、TypeScript 5.8、Vite 7、Tailwind 4、Framer Motion、Lucide、Tauri 2 + Rust；无 shadcn / Ant / MUI 依赖。src/App.tsx、src/components/Sidebar.tsx、src/index.css 为基准来源。

2026-11-02 重新只读核对上述源码与 package.json。1431 登记服务当前为 stopped，本轮没有启动或修改手帐用户状态。已有草稿提及的 11-01 浏览器检查缺少可追溯截图，因此不作为本次验收证据。本次视觉检查针对独立 Design System 示例，不能称为手帐前后对照。

| 角色 | 源码观察 | v0.1 决策 |
| --- | --- | --- |
| 纸底 | App #FAFAF8，侧栏 #F4EFEA/90 | 提取实色基础，支持可选局部半透明 |
| 文字/操作 | #2D323A，#4D7C5D / #3F684C | 保留色相，增加语义别名 |
| 深色 | index.css 最终覆盖 #121214、#1E1F23 | 单列 paper-dark，不替换为暖炭黑 |
| 卡片 | 轻纸影、12px 圆角、点阵、柔和辅助色 | 抽取轻影和圆角；不复制整站装饰 |
| 自定义 | 主题、字体、透明度有用户选项及多重覆盖 | 不宣称只有一套固定配色；不清理既有 CSS |

冲突：旧 UI Skill 预设 planner 必须桌面暖炭黑、字重最高 500；现有手帐有独立配色和较粗标题。此次用户明确要求保留实物，优先于旧默认；新共享组件 400/500 不追溯改手帐。其他桌面产品仍可用 desktop，阅读产品可用 cloud。

本地 canonical scaffold 比 tongyun-work 的旧副本更新（技能名和许可流程已迁移），因此集成 canonical 仓，不向旧副本双写。现有初始化器只生成规则/文档并同步七个商业技能，原先 DESIGN.md 链接没有实际模板；此次显式 --ui 才补齐设计文件和资产。

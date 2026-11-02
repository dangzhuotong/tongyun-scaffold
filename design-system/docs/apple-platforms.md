# Apple 平台策略 · Materials 重新查证 2026-11-02

本页分开记录官方事实和 Tongyun 的实施决定。它是 v0.1 策略，不表示原生功能已经接入。

## 官方依据

Apple [Materials](https://developer.apple.com/design/human-interface-guidelines/materials) 把 Liquid Glass 定位于导航和控制功能层，要求避免用于内容层，并节制自定义效果；regular 侧重文字可读性，clear 面向丰富媒体背景。

[Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) 说明标准 SwiftUI/UIKit/AppKit 组件在相应新 SDK 与系统上采用系统外观，提醒检查自定义导航背景、透明度/动效/对比度设置，并非要求重建整个产品。

[Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views) 提供 glassEffect 与 GlassEffectContainer。本版不调用自定义玻璃 API，以避免没有业务必要的效果和额外渲染成本。

## Tongyun 实施矩阵

| 平台 | 导航/控制 | 内容与降级 |
| --- | --- | --- |
| SwiftUI / UIKit / AppKit 原生 | 优先系统 NavigationStack/SplitView、Tab、toolbar 和标准控件，让系统决定材质；不覆盖其背景 | 手帐正文、任务、表格用稳定不透明表面；文字采用系统动态类型/语义色，校验品牌色 |
| 较旧 Apple 系统 | 使用该系统标准组件外观；新 API 按实际 SDK 的 availability 检查 | 保留相同导航与操作，不以模糊模拟新系统 |
| 现有 Tauri + WebView | 当前标题栏/侧栏多为 React，自带 CSS 不会变成系统材质 | 保留 paper/paper-dark；仅未来确有原生导航桥接时交由系统，不新增 private API 或修改窗口透明配置 |
| Web / 其他平台 | 默认 solid；可显式选择局部 ty-chrome translucency，且须支持 backdrop-filter | @supports 失败直接实色；减少透明/增强对比/强制颜色保底；提供应用内 solid 选项，因为系统透明偏好并非所有浏览器都能传入 |

主题与材质独立，禁止全局给 card/table/正文添加 blur。Web 可选效果是普通渐进增强，不是 Liquid Glass 的复制或平台能力宣称。native 新 API 必须以落地时 Apple SDK 的可用性和最低系统版本核验，当前无 Swift 工程，不伪造编译通过。

## 验收要求

原生：VoiceOver、键盘、Dynamic Type、减少透明/动效、增强对比、浅深色、亮暗/高频背景、窗口缩放；品牌标题和长中文不能遮挡控制。使用系统标准 hit target，触屏至少 44pt 的团队目标。

Web：正文对比 4.5:1，大字 3:1，独立识别控件边界/焦点至少 3:1；键盘顺序和恢复、200% 缩放、320px 视口、触控 44 CSS px、长文、forced-colors。对实际混合背景单独测对比，不能只测 token。

性能：默认零 backdrop-filter；增强只用于少量导航层，不嵌套、不动画 blur；上线前用真实最低支持设备滚动/切页记录帧率与内存，与 solid 基线比较。未完成设备验证前不默认开启。以上为 Tongyun 决定，不是 Apple 对 Web 的规范要求。

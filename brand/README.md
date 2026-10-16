# 云芽

tongyun 官方主标：奶茶色圆角方底，下半部偏中一朵乳白软云，云顶中央长出一片向右上倾斜的抹茶绿叶，叶上一条浅色中脉。扁平，没有阴影。手帐（tongyun-planner）和个人站现用的就是这一枚。

本目录只放主标套件和「云 + 产品符号」变体规则。不改各 App 图标，不动 verse 深绿云，不动心理号夜空云人，也不做售卖物料。

## 色值

取样自现用主标，写死，不要另配。

| 令牌 | 色值 | 用在 |
| --- | --- | --- |
| milk-tea | `#FDC89C` | 圆角方底。峰值约 `#FCC89C`，统一用 `#FDC89C` |
| cloud | `#FCF4E1` | 云，以及叶中脉 |
| sprout | `#A4C48C` | 叶。叶脉可略浅（如 `#B8D4A8`）；本套件中脉直接用云乳白 |
| stroke | `#E8B888` | 可选细描边。主标 SVG 未加，需要勾边时再用 |

圆角约为边长的 25%（1024 画布上 `rx="256"`）。圆角外透明。

## 文件

| 文件 | 用途 |
| --- | --- |
| [yunya-mark.svg](yunya-mark.svg) | 1024×1024 主标源。底、云、芽、中脉各一条路径 |
| [exports/yunya-1024.png](exports/yunya-1024.png) | App icon 源图 |
| [exports/yunya-512.png](exports/yunya-512.png) | 预览、文档 |
| [exports/favicon-48.png](exports/favicon-48.png) | favicon |
| [exports/favicon-96.png](exports/favicon-96.png) | favicon @2x |
| [exports/favicon-180.png](exports/favicon-180.png) | apple-touch 尺寸 |
| [exports/social-preview-1280x640.png](exports/social-preview-1280x640.png) | 社交预览：整幅奶茶底，主标居中，不写字 |

PNG 从 SVG 导出（`rsvg-convert`）。本目录不提交 `.icns` / `.ico`。

## 用法

**App icon。** 以 `exports/yunya-1024.png` 为输入，用下面的 icns/ico 步骤生成各平台尺寸。不要在产品仓里手改像素。

**Favicon。** 48 / 96 / 180 直接用。圆角外是透明；若某个平台把透明渲成黑色，先铺一层 `#FDC89C` 再导出。

**Social Preview。** `social-preview-1280x640.png` 是 1280×640 的 `#FDC89C` 底，正中放 512px 主标，没有字。底和圆角方同色，所以外轮廓会融进背景，画面上是云芽加留白。

## 各 App：云 + 产品符号

变体只换云上的那一个符号，底和云不动。

- 底：奶茶 squircle `#FDC89C`
- 云：乳白 `#FCF4E1`，软云，大约四个叶瓣叠在下半部偏中
- 符号：抹茶绿 `#A4C48C`，从云里长出来或叠在云上
- 扁平，不加投影，不加字

| App | 符号 |
| --- | --- |
| planner | 主标本身（这一片绿芽） |
| api | 云 + 花括号与箭头 |
| dev | 云 + 播放三角 |
| git | 云 + 分支 |

新 App 沿用这套底和云，只换符号。变体画在各产品仓里，不放进本目录。

## 不要做的事

- 不要改主色乱配：不要换掉奶茶底，不要把云做成纯白或灰，不要把芽换成另一套绿。
- 不要在主标或预览图上加售卖文案、价格、折扣。
- 不要用这套主标替换 verse 的深绿云标。
- 不要替换心理号的夜空云人。
- 不要在本目录改各产品仓的图标文件。

## 重新导出 PNG

```bash
rsvg-convert -w 1024 -h 1024 brand/yunya-mark.svg -o brand/exports/yunya-1024.png
rsvg-convert -w 512  -h 512  brand/yunya-mark.svg -o brand/exports/yunya-512.png
rsvg-convert -w 48   -h 48   brand/yunya-mark.svg -o brand/exports/favicon-48.png
rsvg-convert -w 96   -h 96   brand/yunya-mark.svg -o brand/exports/favicon-96.png
rsvg-convert -w 180  -h 180  brand/yunya-mark.svg -o brand/exports/favicon-180.png
```

社交预览图：1280×640 画布填 `#FDC89C`，把主标缩到 512×512 居中贴上（圆角外的透明会露出同色底）。

## icns / ico

推荐在对应的 Tauri 项目里，用 1024 源图一次生成整套（含 `.icns` 和 `.ico`）：

```bash
npx @tauri-apps/cli icon brand/exports/yunya-1024.png
```

已有 Tauri 脚本时：

```bash
npm run tauri icon brand/exports/yunya-1024.png
```

macOS 也可以自己打 `.icns`（`sips` + `iconutil`）：

```bash
mkdir -p Yunya.iconset
sips -z 16 16     brand/exports/yunya-1024.png --out Yunya.iconset/icon_16x16.png
sips -z 32 32     brand/exports/yunya-1024.png --out Yunya.iconset/icon_16x16@2x.png
sips -z 32 32     brand/exports/yunya-1024.png --out Yunya.iconset/icon_32x32.png
sips -z 64 64     brand/exports/yunya-1024.png --out Yunya.iconset/icon_32x32@2x.png
sips -z 128 128   brand/exports/yunya-1024.png --out Yunya.iconset/icon_128x128.png
sips -z 256 256   brand/exports/yunya-1024.png --out Yunya.iconset/icon_128x128@2x.png
sips -z 256 256   brand/exports/yunya-1024.png --out Yunya.iconset/icon_256x256.png
sips -z 512 512   brand/exports/yunya-1024.png --out Yunya.iconset/icon_256x256@2x.png
sips -z 512 512   brand/exports/yunya-1024.png --out Yunya.iconset/icon_512x512.png
sips -z 1024 1024 brand/exports/yunya-1024.png --out Yunya.iconset/icon_512x512@2x.png
iconutil -c icns Yunya.iconset -o Yunya.icns
```

Windows `.ico`（ImageMagick）：

```bash
magick brand/exports/yunya-1024.png -define icon:auto-resize=256,128,64,48,32,16 yunya.ico
```

生成物留在各 App 仓，不提交回本目录。

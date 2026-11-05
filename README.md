# tongyun-scaffold

Tongyun 系列新项目初始化脚手架（公开、MIT）。生成 AI 协作规则、轻量 DDD 文档骨架和项目级 Coding 技能入口，不替项目选技术栈或安装业务依赖。

## 初始化

```bash
bash scripts/init-project.sh "my-app" "一句话用途" /path/to/my-app
```

技能来源为 [dangzhuotong/tongyun-skills](https://github.com/dangzhuotong/tongyun-skills)，需要仓库访问权限，使用与分发遵循该仓商业许可；本脚手架的 MIT 许可不覆盖复制进项目的技能。可指定已有 checkout：

```bash
TONGYUN_SKILLS=/path/to/tongyun-skills bash scripts/init-project.sh my-app "用途" /path/to/my-app
```

写入内容：`AGENTS.md`、`CLAUDE.md` 软链、`docs/` 文档骨架、`.agents/notes/{proposed,implemented,rejected,archived}/`、七个 `.agents/skills/tongyun-*` 实体目录、`.claude/skills` / `.cursor/skills` 软链、`scripts/sync-skills.sh` 和 `.gitignore` 建议项。不要初始化到脚手架自身。

来源不可用时保留项目骨架并警告，后续补跑同步；`SKIP_SKILLS_SYNC=1` 可跳过同步。初始化默认保护已有文件，`FORCE=1` 才覆盖模板。已生成项目更新同步脚本时，先审阅并复制新版 `scripts/sync-skills.sh`，不要用 FORCE 覆盖整套业务文档。

## UI Design System v0.1

以手帐实际纸感界面为基准的轻量共享资产位于 [design-system/](design-system/README.md)。可选接入：

```bash
bash scripts/init-project.sh --ui paper my-app "用途" /path/to/my-app
```

主题支持 paper、paper-dark、desktop、cloud，默认 none，不给后端项目加 UI。生成 `ui/` 和 `DESIGN.md`，接入入口由项目按已有技术栈完成，不安装第二套库；已有文件默认保护。Agent 继续通过独立技能库同步 tongyun-ui-design，本公开仓不放技能正文。

## Coding 技能

现行套装为 `tongyun-product`、`tongyun-ui-design`、`tongyun-api`、`tongyun-test`、`tongyun-code-review`、`tongyun-deploy`、`tongyun-mac-ship`。项目规范在 `tongyun-product/jobs/project/JOB.md`，不是独立技能。

```bash
bash scripts/sync-skills.sh
```

来源和 commit 记录在 `.agents/skills/SOURCES.md`。只管理套装七个精确目录，保留自定义技能。技能随生成项目提交，不装进全局目录；公开项目需先核对技能分发授权。旧 `--edition pro` 和来源变量继续兼容，旧 lite 入口明确拒绝。迁移细节见 [docs/skills.md](docs/skills.md)。

## 轻量 DDD

一个目录对应一块业务能力，写操作走应用入口，跨上下文通过明确接口。根 `AGENTS.md` 维护阅读入口，具体规则在各自文档唯一维护。见 [docs/architecture.md](docs/architecture.md)。

## 验证

```bash
bash scripts/selftest.sh
```

测试使用离线假仓，覆盖初始化、同步、旧命名迁移、来源异常和用户文件保护。CI 在 macOS / Linux 上运行，Linux 另执行 ShellCheck。假仓测试不证明远程权限或真实技能源可用。

## 许可与参考

脚手架 MIT；主标见 [brand/](brand/README.md)。设计记录目录与界面守则的思路参考 [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness)（MIT），按通用项目重写。

Windows Git Bash 需具备创建符号链接的权限（开发者模式/管理员权限，`MSYS=winsymlinks:nativestrict`），或使用 WSL / macOS / Linux；CI 完整自检覆盖 macOS / Linux。

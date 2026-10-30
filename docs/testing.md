# 测试与自检说明

本文档说明 `tongyun-scaffold` 仓库测试套件的运行方式、运行机制以及所覆盖的检查项。文档内容均可从 `scripts/selftest.sh`、`tests/test_init_project.sh` 与 `tests/test_sync_skills.sh` 代码中直接核实。

---

## 1. 运行方式

### 1.1 运行全部自检

脚手架主自检入口为 `scripts/selftest.sh`，它会运行完整的集成测试流程，并在末尾调用 `tests/` 下的专项测试：

```bash
bash scripts/selftest.sh
```

全部断言通过时，终端最后输出 `selftest ok` 且退出码为 0；若任意断言失败，脚本通过 `fail` 函数向标准错误输出错误原因并以退出码 1 终止。

### 1.2 单独运行专项测试

`tests/` 下的测试脚本可独立直接运行：

```bash
# 专项测试 init-project.sh（参数校验、环境变量、软链保护、默认值等）
bash tests/test_init_project.sh

# 专项测试 sync-skills.sh（命令行选项、退出码、文件排除、软链展开、dirty 检测等）
bash tests/test_sync_skills.sh
```

---

## 2. 运行机制与环境隔离

测试脚本遵循以下运行机制：

1. **环境与网络隔离**：
   - 全程离线运行，不发起任何网络请求。
   - 依赖本地假仓（使用 `git init` 构造的本地 git fixture 目录）模拟 lite 与 pro 两个版本的技能来源仓。
2. **临时目录与自动清理**：
   - 每次运行通过 `mktemp -d` 创建沙箱工作目录。
   - 通过 `trap 'rm -rf "$WORK"' EXIT` 确保在测试成功或异常中断时自动清理临时目录，不留磁盘垃圾。
3. **全局目录防护**：
   - 将 `HOME` 重定向到临时目录内部（`$WORK/home`），防止读写或污染用户环境的全局目录（如 `~/.cursor`、`~/.codex`、`~/.workbuddy` 等）。
   - 在测试前后显式 `unset` 相关环境变量（`TONGYUN_SKILLS_*`、`SKIP_SKILLS_SYNC`、`FORCE` 等）。
4. **Shell 兼容性**：
   - 采用 POSIX / bash 3.2+ 兼容语法（兼容 macOS 默认 bash、Linux bash 与 Windows Git Bash）。
   - Windows Git Bash 还需能创建符号链接（开发者模式/管理员权限并设置 `MSYS=winsymlinks:nativestrict`），否则软链断言会失败；CI 只在 Linux / macOS 跑完整自检。
   - 启用 `set -euo pipefail` 确保未定义变量、命令管道故障即时中断。

---

## 3. 检查项清单

### 3.1 `scripts/selftest.sh` 端到端集成测试

| 阶段 | 检查目标 | 具体断言与验证逻辑 |
| --- | --- | --- |
| `[0/12]` | 本仓不含 skill 正文 | 使用 `git ls-files` 验证脚手架本仓未跟踪任何以 `SKILL.md` 结尾的文件。 |
| `[1/12]` | 初始生成、特殊字符与 skill 复制 | 传入包含 `&`、`\`、`\|` 等特殊字符的项目名和用途，验证模板占位符转义正确；验证 `AGENTS.md`、`docs/`、`scripts/sync-skills.sh`、`.gitignore` 等骨架文件生成；验证默认复制 7 个 lite skill 实体文件；验证 `.claude/skills`、`.cursor/skills`、`CLAUDE.md` 软链正确；验证排除 `tests` 与临时文件；验证 `SOURCES.md` 包含 `edition: lite` 与 commit SHA。 |
| `[2/12]` | 二次运行不覆盖已改动文件 | 模拟修改生成的 `AGENTS.md`，添加项目自定义 skill，二次运行 `init-project.sh`：验证输出包含跳过提示；已修改的 `AGENTS.md` 未被覆盖；`tong-*` skill 原地刷新；自定义项目 skill 未被删除。 |
| `[3/12]` | FORCE=1 覆盖 | 设置环境变量 `FORCE=1` 再次运行 `init-project.sh`：验证已修改的 `AGENTS.md` 被重新渲染覆盖。 |
| `[4/12]` | lite 与 pro 版本切换 | 运行 `sync-skills.sh --edition pro`：验证 7 个 skill 切换为 pro 版且原 lite 目录被清理；`SOURCES.md` 记录 `edition: pro`、commit SHA 且 URL 凭据脱敏；`AGENTS.md` 链接改为 pro；不带参数重跑沿用 pro；设置 `TONGYUN_SKILLS_EDITION=lite` 可切回 lite；传入非法版本退出。 |
| `[5/12]` | init --edition pro | 运行 `init-project.sh --edition pro`：验证初始化直接生成 pro 版 skill 并更新 `AGENTS.md` 链接；验证非法版本报错退出。 |
| `[6/12]` | 旧 .gitignore 规则迁移 | 在目标项目已有 `.gitignore` 中预设自定义规则与旧 skills 忽略规则：验证运行后自定义规则保留，旧 skills 忽略规则被移除。 |
| `[7/12]` | 来源仓不可达时降级与警告 | 在无本地缓存且远程 git 地址不可达时执行 init：验证主体项目文件依然生成，终端打印后续手动运行 `sync-skills.sh` 的警告，磁盘未残留损坏的 git 缓存。 |
| `[8/12]` | 保护脚手架仓自身 | 验证将目标路径设为脚手架仓库根目录时，`sync-skills.sh` 与 `init-project.sh` 均拒绝执行并以非零状态码退出。 |
| `[9/12]` | 全局目录防污染 | 验证测试期间隔离的 `$HOME` 下未产生 `.cursor`、`.codex`、`.workbuddy` 目录。 |
| `[10/12]` | 调用 init-project 专项测试 | 执行 `bash tests/test_init_project.sh`。 |
| `[11/12]` | 调用 sync-skills 专项测试 | 执行 `bash tests/test_sync_skills.sh`。 |
| `[12/12]` | 测试结束时脚手架无 skill 残留 | 验证脚手架本仓目录下未被写入任何 `tong-*` 目录。 |

---

### 3.2 `tests/test_init_project.sh` 专项测试

| 检查项 | 触发条件 | 预期行为与断言 |
| --- | --- | --- |
| 1. `--edition` 参数缺失或非法 | 传入 `--edition`（无值）或 `--edition=invalid` | 退出码为 2；向 stderr 输出 `--edition 需要 lite 或 pro` 或 `版本只能是 lite 或 pro`。 |
| 2. `SKIP_SKILLS_SYNC=1` | 环境变量设置 `SKIP_SKILLS_SYNC=1` | 终端打印跳过提示；生成 `AGENTS.md`、`docs/prd.md`、`scripts/sync-skills.sh` 等；不复制任何 `tong-*` skill；不生成 `SOURCES.md`。 |
| 3. `--edition=pro` 等号形式 | 传入 `--edition=pro` | 复制 7 个 `tong-*-pro` skill；`SOURCES.md` 记录 `edition: pro`；`AGENTS.md` 中的链接指向 pro 版本。 |
| 4. `TONGYUN_SKILLS_EDITION=pro` | 环境变量设置 `TONGYUN_SKILLS_EDITION=pro` | 不传 `--edition` 时默认采用 pro 版本，生成 pro skill 与相应 `SOURCES.md`。 |
| 5. 软链保护：已存在实体文件 | 目标目录下已存在普通实体文件 `CLAUDE.md` | 终端输出跳过提示；`CLAUDE.md` 保持为实体文件（不被强行替换为软链），原内容完整保留。 |
| 6. 默认参数行为 | 不传项目名、用途和目标目录参数在子目录执行 | 项目名默认为 `my-project`，用途默认为 `（待填写项目用途）`，在当前目录下完成初始化。 |
| 7. 目标路径末尾带斜杠 | 传入结尾带斜杠的路径（如 `path/to/dir/`） | 正确剥离末尾斜杠，项目文件正常生成在目标目录下。 |
| 8. 默认 `.gitignore` 生成 | 初始化新目录（无已有 `.gitignore`） | 生成包含 `node_modules/`、`.env`、`!.env.example` 等规则的默认 `.gitignore`。 |

---

### 3.3 `tests/test_sync_skills.sh` 专项测试

| 检查项 | 触发条件 | 预期行为与断言 |
| --- | --- | --- |
| 1. 帮助选项 | 传入 `-h` 或 `--help` | 退出码为 0；向终端输出用法说明（`用法：bash scripts/sync-skills.sh`）。 |
| 2. 未知选项与参数错误 | 传入 `--unrecognized-opt`、多余位置参数、缺少值的 `--edition`、或不存在的项目目录 | 退出码为 2；输出对应错误信息（如 `未知参数`、`项目目录不存在`）。 |
| 3. 源目录异常处理 | 传入缺少 `skills/` 的源目录，或源中某个 skill 缺少 `SKILL.md` | 退出码为 1；向 stderr 输出 `下没有 skills/ 目录` 或 `源里缺`；不破坏目标项目。 |
| 4. 默认目标目录 | 在项目根目录下执行 `bash scripts/sync-skills.sh`（不传目标路径） | 自动以脚本上一级目录作为项目根目录，成功同步并生成 `SOURCES.md`。 |
| 5. 软链展开为实体文件 | 源目录中包含符号链接文件（如 `references/link.md -> a.md`） | 复制到目标后展开为普通实体文件（`! -L` 且 `-f`），内容与源目标一致。 |
| 6. 排除临时文件与目录 | 源目录中包含单数 `test/`、`__pycache__`、`.pytest_cache`、`tmp/` 目录或 `*.pyc`、`*.tmp`、`*.swp`、`*~` 等文件 | 目标目录中这些临时目录与文件均被排除或删除。 |
| 7. Git dirty 状态检测 | 源 git 仓库存在未提交修改（工作区 dirty） | 同步后生成的 `SOURCES.md` 表格中，对应 skill 的 commit SHA 带有 `+dirty` 后缀。 |
| 8. 真实目录保护 | 目标项目中的 `.claude/skills` 为真实实体目录而非软链 | 终端打印警告提示；保留真实目录（不替换为软链），目录内已有文件不受影响。 |

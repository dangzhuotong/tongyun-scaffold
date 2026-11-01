# 测试与自检

全套入口：`bash scripts/selftest.sh`，成功末尾输出 `selftest ok`。也可分别运行 `bash tests/test_init_project.sh` 和 `bash tests/test_sync_skills.sh`。

所有测试使用临时来源仓、项目和缓存，不连接远程、不修改用户 HOME、不启动项目服务。测试结束清理临时目录。兼容 macOS 系统 Bash 3.2；CI 还在 Linux 执行 ShellCheck。

覆盖：模板特殊字符、默认值、七个现行 tongyun 工种、project JOB 链接、客户端软链、默认重复运行保护与 FORCE、gitignore 自定义规则、来源 commit 与 dirty 标记、来源 URL 凭据脱敏、缺失源或 JOB 时目标保持不变、旧命名和 pro 参数兼容、精确清理旧工种与自定义技能保留、重复迁移幂等、lite 明确拒绝、离线骨架降级、禁止向脚手架写技能正文。

假仓通过不能证明真实技能仓目录、权限或来源版本可用。使用真实来源时，在临时项目中初始化并核对所有模板技能链接、project JOB、七个目录和来源记录，再重复同步确认自定义规则保留。技能文件不应作为验证产物放进本公开仓。

Windows Git Bash 需具备创建符号链接的权限（开发者模式/管理员权限，`MSYS=winsymlinks:nativestrict`），或使用 WSL / macOS / Linux；CI 完整自检覆盖 macOS / Linux。

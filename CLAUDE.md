# WoAccount - Claude Code 项目规范

## Git 提交规范

本项目使用 Conventional Commits 规范，每次文件修改后必须执行 git 提交。

### 流程

1. `git diff` 检查变更
2. `git add` 暂存文件（绝不提交 .env、密钥等敏感文件）
3. 生成规范的 commit message 并提交
4. `git push` 推送到远程仓库并同步

### Commit 格式

```
<type>[optional scope]: <description>

[optional body]

[optional footer]
```

### Type 类型

| Type | 用途 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `docs` | 仅文档变更 |
| `style` | 格式/样式（不影响逻辑） |
| `refactor` | 重构（非新功能/修复） |
| `perf` | 性能优化 |
| `test` | 添加/修改测试 |
| `build` | 构建系统/依赖变更 |
| `ci` | CI/配置变更 |
| `chore` | 杂项维护 |
| `revert` | 回滚提交 |

### Scope 范围

参考项目模块：`ai` / `transaction` / `category` / `stats` / `budget` / `settings` / `db` / `config`

### 示例

```
feat(ai): add natural language query support
fix(transaction): correct amount parsing for decimal values
docs: update architecture to local-first approach
refactor(db): simplify repository layer
```

### 安全约束

- 不更新 git config
- 不执行破坏性命令（--force、hard reset）
- 不跳过 hooks（--no-verify）
- 不 force push 到 main
- hook 失败时修复后新建提交，不 amend

## 真机部署规范

所有真机调试和部署统一使用 **debug 模式**，不使用 release 模式。

```
flutter run -d <device_id>
```

Debug 模式构建速度快（约 15-20 秒），支持热重载（`r`）和热重启（`R`），适合开发调试。Release 模式首次构建需要数分钟，不适合迭代开发。

---
name: bootstrap-workflow
description: 在目标项目中初始化 loop-workflow 的项目级基础设施，不创建具体 story。
sources:
  - reference/gstack/CLAUDE.md
  - workflow/design/workflow-framework.md
  - workflow/design/test-as-contract-workflow.md
---

# bootstrap-workflow

在目标项目中初始化 **双循环**（Two-Loop）工作流所需的项目级基础设施。

本 skill 不创建具体 story，也不复制 skill 目录；它只负责建立 `.aiassist/` 目录结构和版本控制约定。Story 创建请使用 `/story`。

## 执行步骤

### 1. 确认当前目录是目标项目根目录

如果当前目录不是目标项目根目录，停下来询问用户。

### 2. 创建 `.aiassist/` 基础设施

按以下结构创建目录和初始文件：

```
.aiassist/
├── global/
│   ├── CONTEXT.md              # 领域词汇表（由 /domain-model 维护）
│   ├── business-capabilities.md # 业务能力地图（由 /crystallize、/reflect 维护）
│   ├── adr/                    # 架构决策记录目录
│   │   └── README.md           # ADR 索引
│   ├── codegraph.json          # CodeGraph 配置（可选）
│   ├── DESIGN.md               # 项目级设计系统文档（如不存在则创建模板）
│   ├── tokens.css              # 设计 token（如不存在则创建空文件）
│   ├── architecture.md         # 架构概览（不再承载具体决策）
│   ├── engineering-lessons.md  # 工程经验教训
│   └── STANDARDS.md            # 编码与流程标准
├── stories/                    # story 目录，初始为空
└── hooks/                      # git hooks
    ├── pre-commit
    └── commit-msg
```

从 workflow 模板复制：

- `templates/claude/project-claude-appendix.md.template` → 追加到目标项目 `CLAUDE.md`
- `templates/global/CONTEXT.md.template` → `.aiassist/global/CONTEXT.md`
- `templates/global/business-capabilities.md.template` → `.aiassist/global/business-capabilities.md`
- `templates/global/adr/README.md.template` → `.aiassist/global/adr/README.md`
- `templates/global/adr/NNNN-title.md.template` → 保留在 workflow 内，由 `/tech-design` 和 `/reflect` 使用
- `templates/global/architecture.md.template` → `.aiassist/global/architecture.md`
- `templates/global/codegraph.json.template` → `.aiassist/global/codegraph.json`
- `templates/story/prd.md.template` → 保留在 workflow 内，由 `/story` 使用
- `templates/story/requirements.md.template` → 保留在 workflow 内，由 `/story` 使用
- `templates/story/workflow-state.yaml.template` → 保留在 workflow 内，由 `/story` 使用
- `templates/hooks/pre-commit` → `.aiassist/hooks/pre-commit`
- `templates/hooks/commit-msg` → `.aiassist/hooks/commit-msg`

### 2.5 选择技术栈并创建 CI/CD 门禁模板

如果目标项目使用 GitHub Actions，按以下顺序确定技术栈：

1. **自动检测**（根据项目文件）：
   - `package.json` → Node.js
   - `requirements.txt` / `pyproject.toml` → Python
   - `Package.swift` / `*.xcodeproj` / `*.xcworkspace` → Swift
   - `go.mod` → Go
   - 其他 → Generic

2. **向用户确认或询问**：
   - 如果检测到明确技术栈，告诉用户："检测到你是 Node.js 项目，是否使用 Node.js 模板？"
   - 如果未检测到，给出选项：
     - Node.js
     - Python
     - Swift
     - Go
     - Generic（空白模板，自己填命令）

3. **复制对应模板**：

   - Node.js → `templates/github/workflows/contract-gate.node.yml` → `.github/workflows/contract-gate.yml`
   - Python → `templates/github/workflows/contract-gate.python.yml` → `.github/workflows/contract-gate.yml`
   - Swift → `templates/github/workflows/contract-gate.swift.yml` → `.github/workflows/contract-gate.yml`
   - Go → `templates/github/workflows/contract-gate.go.yml` → `.github/workflows/contract-gate.yml`
   - Generic → `templates/github/workflows/contract-gate.generic.yml` → `.github/workflows/contract-gate.yml`

4. **提醒用户微调**：即使是自动选择的模板，也需要检查：
   - 项目实际的脚本命令（`package.json` 里的 scripts，或 `pytest` 参数等）
   - Swift 项目的 scheme 名称、destination
   - coverage 阈值
   - lint / typecheck 工具

本门禁始终包含以下检查：

1. 静态检查（lint / typecheck，按技术栈）
2. 单元测试 + coverage
3. E2E 测试
4. `signoff.md` 存在性检查（assertion 阶段签核后生成）
5. 实现 PR 不能同时修改测试文件

### 3. 可选：启用 CodeGraph（代码知识图谱）

询问用户是否启用 CodeGraph 辅助 AI 理解代码结构：

> CodeGraph 能自动构建代码知识图谱，减少 AI 实现时的 grep/read 开销。是否启用？（推荐）

如果用户同意：

1. 提示安装 CodeGraph CLI：
   ```bash
   npm i -g @colbymchenry/codegraph
   # 或
   curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
   ```
2. 运行：
   ```bash
   codegraph init
   ```
3. 将 `.aiassist/global/codegraph.json` 中的 `enabled` 改为 `true`。
4. 提醒用户：CodeGraph 是可选加速工具，未安装时不影响工作流。

如果用户拒绝，保持 `codegraph.json` 中 `enabled: false`。

### 4. 配置 git hooks

将项目 git hooks 路径指向 `.aiassist/hooks/`：

```bash
git config core.hooksPath .aiassist/hooks
chmod +x .aiassist/hooks/pre-commit
chmod +x .aiassist/hooks/commit-msg
```

如果目标项目已经使用 husky 或其他 hooks 管理工具，不要覆盖 `core.hooksPath`。改为：

1. 将 `pre-commit` 和 `commit-msg` 脚本的内容合并进 husky 对应 hook；或
2. 在 husky hook 中调用 `.aiassist/hooks/pre-commit` 和 `.aiassist/hooks/commit-msg`。

### 5. 初始化全局文件模板

如果文件不存在，创建：

- `.aiassist/global/CONTEXT.md`
- `.aiassist/global/business-capabilities.md`
- `.aiassist/global/adr/README.md`
- `.aiassist/global/codegraph.json`
- `.aiassist/global/DESIGN.md`
- `.aiassist/global/tokens.css`
- `.aiassist/global/architecture.md`
- `.aiassist/global/engineering-lessons.md`
- `.aiassist/global/STANDARDS.md`

这些文件内容由 `/domain-model`、`/crystallize`、`/reflect`、`/design`（模式 A）、`/tech-design` 等 skill 后续填充。

### 6. 更新项目 `CLAUDE.md`

将 `templates/claude/project-claude-appendix.md.template` 的内容追加到目标项目 `CLAUDE.md` 末尾。如果已经存在双循环附录，跳过。

### 7. 提交初始化变更

```bash
git add .aiassist/ .github/workflows/ CLAUDE.md
git commit -m "[bootstrap] 初始化双循环工作流基础设施"
```

注意：`.aiassist/` 和 `.github/workflows/` 目录本身应被纳入版本控制，但具体 story 目录下的中间产物是否提交由团队决定。建议至少提交：

- `.aiassist/global/*`
- `.aiassist/hooks/*`
- `.github/workflows/contract-gate.yml`
- `CLAUDE.md`

## commit 标签约定

初始化完成后，目标项目的所有 story 相关 commit 应使用以下标签：

| 标签 | 用途 | 可修改的文件 |
|---|---|---|
| `[test]` | test-author 编写/修改测试、人签核断言 | 测试文件（`test/`、`*.test.*`、`e2e/` 等） |
| `[build]` | implementer 编写/修改实现 | 实现代码（`src/`、`app/`、`lib/` 等） |
| `[bootstrap]` | 工作流基础设施变更 | `.aiassist/`、`CLAUDE.md`、hooks 等 |
| `[docs]` | PRD、需求、设计文档更新 | `.aiassist/stories/*/prd.md`、`.aiassist/stories/*/requirements.md` 等 |
| `[ux]` | UX 原型更新 | `.aiassist/stories/*/ux/*.html`、`.aiassist/global/DESIGN.md` 等 |

核心纪律：**一个 commit 不能同时包含实现代码和测试文件**。git hooks 会拦截这种 commit。

## 输出

初始化完成后，向用户确认：

1. `.aiassist/` 目录已创建（包含 CONTEXT.md、business-capabilities.md、adr/、codegraph.json 等全局文档）
2. git hooks 已配置（或已说明 husky 兼容方案）
3. `CLAUDE.md` 已更新
4. CodeGraph 状态（已启用 / 未启用）
5. 下一步可以运行 `/story` 开始第一个 story

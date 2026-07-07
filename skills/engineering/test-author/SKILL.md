---
name: test-author
description: 从 REQ 生成可执行的业务测试骨架（验收测试）。默认把产品 CLI 当作首要测试 seam，不能 CLI 化的行为退到浏览器 E2E 或 public API/函数接口测试。用占位符标记等人签断言。不写实现代码，不写 TDD 单元测试。
sources:
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - reference/superpowers/skills/test-driven-development/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# test-author

## 何时调用

`requirements.md` 已确认，用户说"写测试骨架"、"/test-author"时。或被 `/story` 总入口调用。

## 输入

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/requirements-v1.hash`
- `.aiassist/stories/<id>/tech-design.md`（其中定义了 seams：CLI / 单元 / 浏览器 E2E）
- `.aiassist/stories/<id>/ux/*.html`（如有 UX 原型，作为结构与行为测试的输入）
- 项目 `CLAUDE.md` 中声明的 CLI 入口（如有）

## 输出

- 业务测试文件（验收测试，按项目约定目录，如 `tests/`、`src/__tests__/`、`Tests/**/*.swift` 等）
  - CLI 测试：`<story-id>/cli/*.test.sh` 或 `*.test.ts`
  - API / public 函数接口测试：按语言框架惯例
  - 浏览器 E2E：`<story-id>/e2e/*.test.ts` 等
- `.aiassist/stories/<id>/test-plan.md`

**不输出**：TDD 单元测试。单元测试由 `/implementer` 在实现过程中自行写、自行维护。

## 执行步骤

1. **读取 seams 声明**：从 `tech-design.md` 读取每个 REQ-ID 对应的 seam 类型。默认假设：**能用 CLI 测的，优先用 CLI 测**。
2. **逐条读取 REQ 与 tech-design.md**：按 seams 为每条验收标准设计至少一个测试方法/命令。
3. **读取 HTML UX 原型**：如果 `ux/` 目录存在，扫描所有 `.html` 文件，提取可验证的行为与结构项：
   - 关键元素是否存在（如按钮、表单、列表、空态提示）。
   - 页面/组件之间的导航流程（点击 A → 出现 B）。
   - 交互状态（loading、empty、error、success、disabled）。
   - 数据驱动的列表/卡片结构。
   - 与 token.css 关联的 class/style 是否被正确引用（不验证具体像素值）。
   把这些可验证项映射到对应 REQ-ID，补充进测试计划。浏览器测试只在必要时生成。
4. **写测试文件头部**：必须包含 `REQ-TRACE`、`REQ-VERSION`、`TEST-AUTHOR`、`ASSERTIONS-SIGNED`。
5. **按 seam 类型搭建脚手架**：
   - **CLI seam**：生成调用产品 CLI 的测试，断言 stdout/stderr/exit code/文件 side effect。参考[CLI 测试模板](#cli-测试模板)。
   - **API / public 函数 seam**：生成对 public 接口的调用测试，断言返回值/可观察行为。这是业务边界测试，不是实现细节测试。
   - **浏览器 E2E seam**：只在 CLI 和 public 接口都无法覆盖的复杂前端交互时生成。
6. **占位断言**：在需要人拍预期值的地方写 `// TODO: HUMAN ASSERTION`。
7. **编译/可执行检查**：确保测试文件能运行（可能需要临时 stub 实现或 CLI 入口）。
8. **输出 test-plan.md**：列出每个 REQ-ID 对应哪些测试方法/CLI 命令，并标注 seam 类型和哪些测试来自 HTML 原型映射。

## 测试头部模板

```swift
// REQ-TRACE: REQ-P0-001, REQ-P0-002
// REQ-VERSION: v1-hash:a3f7d2e
// TEST-AUTHOR: agent
// ASSERTIONS-SIGNED: false
```

## CLI 测试模板

CLI 是产品功能，也是测试 seam。CLI 测试不依赖浏览器，直接调用真实命令并断言可观察行为。

### 模板 A：shell 脚本（适合任何 CLI）

```bash
#!/usr/bin/env bash
set -euo pipefail

# REQ-TRACE: REQ-P0-001
# REQ-VERSION: v1-hash:a3f7d2e

CLI="${CLI:-./myapp}"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# TODO: HUMAN ASSERTION — 填入预期输出/退出码/副作用
$CLI project create --name "demo" --output-dir "$TMPDIR"
# 预期: 退出码 0，目录 $TMPDIR/demo 存在，包含 project.json
# [[ -d "$TMPDIR/demo" ]]
# [[ -f "$TMPDIR/demo/project.json" ]]
```

### 模板 B：TypeScript/Node（适合已有 JS/TS 生态的项目）

```ts
// REQ-TRACE: REQ-P0-001
// REQ-VERSION: v1-hash:a3f7d2e

import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { execSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

describe("project create", () => {
  let workdir: string;

  beforeEach(() => {
    workdir = mkdtempSync(join(tmpdir(), "loop-"));
  });

  afterEach(() => {
    rmSync(workdir, { recursive: true, force: true });
  });

  it("creates a project with the given name", () => {
    const out = execSync(`./myapp project create --name demo --output-dir ${workdir}`, {
      encoding: "utf-8",
    });

    // TODO: HUMAN ASSERTION — 填入预期输出
    // expect(out).toContain("Created project demo");
    // expect(existsSync(join(workdir, "demo", "project.json"))).toBe(true);
  });
});
```

### CLI 测试纪律

- 每个 CLI 测试必须指定：命令、输入（参数/stdin/环境变量）、预期输出（stdout/stderr/退出码）、副作用（文件/DB/网络）。
- 测试之间必须隔离状态：使用临时目录、独立 DB、或 CLI 提供的 `--reset-state`。
- 不测试实现细节，只测试可观察行为。
- 不要把主观视觉判断放进 CLI 测试；观感走 feel-signoff。

## 纪律

- **只写测试，不写实现代码**。
- 预期值**不**从当前代码抄写；用占位符等人签。
- 默认**禁用快照当判定依据**。
- **CLI 优先**：能用产品 CLI 验证的行为，先生成 CLI 测试；不能 CLI 化的才进单元或浏览器 E2E。
- CLI 测试必须跑在真实命令上，不绕过权限/校验/副作用（清理命令除外）。
- 能用 CLI 测的，不进浏览器 E2E（缺陷下沉原则）。
- 覆盖：正常路径 + 边界 + 错误路径。
- **HTML 原型是测试输入**：从 HTML 中提取行为和结构，但不把主观视觉（如“间距 12px 才好看”）写进测试。

## 与参考项目的差异

- mattpocock `tdd`：给我们"红绿重构"和测试先行的纪律。
- superpowers `test-driven-development`：给我们铁律和常见反模式清单。
- 核心差异：测试作者和实现者必须分离；断言归人。

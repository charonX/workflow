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
- `.aiassist/global/business-capabilities.md`（能力地图，决定测试目录结构）
- `.aiassist/global/CONTEXT.md`（统一术语与实体命名）
- `.aiassist/global/checklists/testing.md`（测试模式与反模式参考）
- 项目 `CLAUDE.md` 中声明的 CLI 入口（如有）

## 输出

- 业务测试文件（验收测试），按 **业务能力 → 实体** 组织：
  - 目录结构：`tests/capabilities/<capability>/<entity>/<story-id>/`
  - CLI 测试：`.../<story-id>/cli/*.test.sh` 或 `*.test.ts`
  - API / public 函数接口测试：`.../<story-id>/api/*.test.*`
  - 组件/结构测试：`.../<story-id>/component/*.test.*`
  - 浏览器 E2E：`.../<story-id>/e2e/*.test.*`
- `.aiassist/stories/<id>/test-plan.md`

**不输出**：TDD 单元测试。单元测试由 `/implementer` 在实现过程中自行写、自行维护。

## 执行步骤

1. **读取 seams 与 capability/entity 声明**：从 `tech-design.md` 读取每个 REQ-ID 对应的 seam 类型，从 `requirements.md` 读取每个 REQ 的 `capability` 和 `entity`。如果存在冲突或缺失，先调用 `/domain-model` 统一术语。
2. **按 capability/entity 规划目录**：根据 `business-capabilities.md`，为每个 REQ 确定测试目录 `tests/capabilities/<capability>/<entity>/<story-id>/`。如果 capability/entity 是新的，在 `business-capabilities.md` 中预留条目（由 `/crystallize` 最终维护，但 `/test-author` 不应重复造名）。
3. **逐条读取 REQ 与 tech-design.md**：按 seams 为每条验收标准设计至少一个测试方法/命令。
4. **读取 HTML UX 原型（强制提取结构/行为测试）**：如果 `ux/` 目录存在，扫描所有 `.html` 文件，为每个原型提取可验证项并生成至少一个自动化测试：
   - 关键元素是否存在（如按钮、表单、列表、canvas、node palette、properties panel）。
   - 页面/组件之间的导航流程（点击 A → 出现 B，路由跳转）。
   - 交互状态（loading、empty、error、success、disabled、主题切换、语言切换）。
   - 数据驱动的列表/卡片结构。
   - 前端调用 `/api/*` 的参数/时机（可用 mock server / MSW / stub）。
   - 与 token.css 关联的 class/style 是否被正确引用（不验证具体像素值）。
   把这些可验证项映射到对应 REQ-ID，生成组件测试或浏览器 E2E 测试。**禁止以“这是 feel-signoff 项”为由跳过自动化。** 只有纯审美判断（颜色、间距、动效曲线）才允许不生成测试，且需在 `test-plan.md` 中明确标注。
5. **写测试文件头部**：必须包含 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`、`TEST-AUTHOR`、`ASSERTIONS-SIGNED`。
6. **按 seam 类型搭建脚手架**：
   - **CLI seam**：生成调用产品 CLI 的测试，断言 stdout/stderr/exit code/文件 side effect。参考[CLI 测试模板](#cli-测试模板)。
   - **API / public 函数 seam**：生成对 public 接口的调用测试，断言返回值/可观察行为。这是业务边界测试，不是实现细节测试。
   - **组件/结构 seam**：对前端组件/页面生成渲染测试，断言关键元素存在、交互状态变化、数据驱动结构。参考[组件测试模板](#组件测试模板)。
   - **浏览器 E2E seam**：覆盖跨页面流程、真实浏览器事件、路由跳转等组件测试无法覆盖的场景。参考[浏览器 E2E 测试模板](#浏览器-e2e-测试模板)。
   - 不能用 CLI/API/组件/浏览器覆盖的行为（如纯审美）才允许标记为 `人工(仅视觉)`，并在 `test-plan.md` 中说明理由。
7. **占位断言**：在需要人拍预期值的地方写 `// TODO: HUMAN ASSERTION`。
8. **编译/可执行检查**：确保测试文件能运行（可能需要临时 stub 实现或 CLI 入口）。
9. **输出 test-plan.md**：列出每个 REQ-ID 对应哪些测试方法/CLI 命令，并标注：
   - seam 类型
   - capability/entity
   - 哪些测试来自 HTML 原型映射
   - 哪些内容留给 `feel-signoff`（仅限纯审美判断，需说明理由）
10. **回溯检查**：扫描所有 REQ-ID，确认每个 REQ 至少有一个自动化测试。如果某个 REQ 只有 `人工(仅视觉)` 测试，检查 `/crystallize` 的分类是否合法；不合法则回流 `/crystallize`。
11. **不修改 business-capabilities.md**：能力地图由 `/crystallize` 生成，`/test-author` 只读取并按其结构组织测试。如果发现能力地图与 REQ 不一致，回流 `/crystallize`。

## 测试头部模板

```swift
// REQ-TRACE: REQ-P0-001, REQ-P0-002
// REQ-VERSION: v1-hash:a3f7d2e
// CAPABILITY-TRACE: <capability-name>
// ENTITY-TRACE: <entity-name>
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
# CAPABILITY-TRACE: <capability-name>
# ENTITY-TRACE: <entity-name>

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
// CAPABILITY-TRACE: <capability-name>
// ENTITY-TRACE: <entity-name>

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

## 组件测试模板

组件/结构测试验证前端渲染、元素存在、交互状态变化。不测像素值、颜色、间距等审美细节。

### 模板 C：React + Testing Library（JS/TS 项目）

```tsx
// REQ-TRACE: REQ-FLOW-003
// REQ-VERSION: v1-hash:a3f7d2e
// CAPABILITY-TRACE: flow-orchestration
// ENTITY-TRACE: flow

import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import { FlowEditor } from "../src/renderer/components/FlowEditor";

describe("FlowEditor", () => {
  it("renders canvas and node palette", () => {
    render(<FlowEditor flowId="demo" />);

    // TODO: HUMAN ASSERTION — 确认元素文案/角色
    expect(screen.getByTestId("flow-canvas")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /add node/i })).toBeInTheDocument();
  });

  it("switches theme when toggle is clicked", () => {
    render(<FlowEditor flowId="demo" />);

    const toggle = screen.getByRole("button", { name: /toggle theme/i });
    fireEvent.click(toggle);

    // TODO: HUMAN ASSERTION — 确认 theme 切换后的属性/类名
    expect(document.documentElement.dataset.theme).toBe("dark");
  });
});
```

### 组件测试纪律

- 每个组件测试必须对应一个 REQ 中的结构或行为验收标准。
- 使用 `data-testid` 或 ARIA role 定位元素，不要依赖 CSS 类名或 DOM 层级。
- 不验证具体样式值（color、font-size、margin），这些走 feel-signoff。
- 必须验证交互后的状态变化（props、context、data-attribute、localStorage、fetch 调用等）。
- API 调用可用 MSW 或简单 stub/mock，但断言必须验证调用参数/时机。

## 浏览器 E2E 测试模板

浏览器 E2E 覆盖跨页面流程、真实浏览器事件、路由跳转等组件测试无法覆盖的场景。

### 模板 D：Playwright（JS/TS 项目）

```ts
// REQ-TRACE: REQ-FLOW-003
// REQ-VERSION: v1-hash:a3f7d2e
// CAPABILITY-TRACE: flow-orchestration
// ENTITY-TRACE: flow

import { test, expect } from "@playwright/test";

test("user can open flow editor and see canvas", async ({ page }) => {
  // TODO: HUMAN ASSERTION — 填入正确的启动 URL/路由
  await page.goto("http://localhost:3000/flows/demo");

  await expect(page.getByTestId("flow-canvas")).toBeVisible();
  await expect(page.getByRole("button", { name: /add node/i })).toBeVisible();
});

test("user can navigate from workspace to flow editor", async ({ page }) => {
  await page.goto("http://localhost:3000/workspace");
  await page.click("text=demo-flow");

  await expect(page).toHaveURL(/\/flows\/demo/);
  await expect(page.getByTestId("flow-canvas")).toBeVisible();
});
```

### 浏览器 E2E 纪律

- E2E 只在组件测试无法覆盖的跨页面/跨进程流程时使用（缺陷下沉原则）。
- 每个 E2E 测试必须指定：起始状态、用户操作、预期可观察结果（URL、元素可见性、文本内容）。
- 不要验证像素级样式；观感走 feel-signoff。
- 测试数据必须隔离，避免污染其他测试。

## 纪律

- **只写测试，不写实现代码**。
- **每个 REQ 必须至少有一个自动化测试**：没有自动化测试的 REQ 不能进入 assertion-signoff。如果 `/crystallize` 把某 REQ 标为 `人工(仅视觉)`，`/test-author` 必须回溯检查它是否真的只涉及审美；否则回流 `/crystallize`。
- 预期值**不**从当前代码抄写；用占位符等人签。
- 默认**禁用快照当判定依据**。
- **CLI 优先**：能用产品 CLI 验证的行为，先生成 CLI 测试；不能 CLI 化的才进 API/组件/浏览器 E2E。
- CLI 测试必须跑在真实命令上，不绕过权限/校验/副作用（清理命令除外）。
- **组件/结构测试覆盖前端行为**：从 HTML 原型中提取元素存在性、交互状态、导航流程、API 调用，生成组件测试。只有纯审美判断才允许不生成自动化测试。
- **浏览器 E2E 是最后手段**：能用组件测试覆盖的，不进浏览器 E2E（缺陷下沉原则）。
- 覆盖：正常路径 + 边界 + 错误路径。
- **遵循 `checklists/testing.md`**：测试结构、命名、断言、mock 边界、反模式参照项目检查清单。
- **HTML 原型是测试输入**：从 HTML 中提取行为和结构，但不把主观视觉（如“间距 12px 才好看”）写进测试。
- **测试按 capability/entity 组织**：目录结构必须反映 `business-capabilities.md` 中的能力地图。
- **头部必须含 CAPABILITY-TRACE 和 ENTITY-TRACE**：这是连接 story 测试与长期业务能力资产的纽带。

## 与参考项目的差异

- mattpocock `tdd`：给我们"红绿重构"和测试先行的纪律。
- superpowers `test-driven-development`：给我们铁律和常见反模式清单。
- 核心差异：测试作者和实现者必须分离；断言归人；测试按业务能力/实体组织，服务于长期资产视图。

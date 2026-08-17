---
name: implementer
description: 内层实现循环的核心。在已签核的测试契约内，通过子代理实现每个切片；父代理负责读取设计上下文、调度、验证。支持显式降级到当前上下文自循环。
sources:
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
  - reference/superpowers/skills/executing-plans/SKILL.md
  - reference/superpowers/skills/verification-before-completion/SKILL.md
  - reference/superpowers/skills/finishing-a-development-branch/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - reference/mattpocock/skills/engineering/implement/SKILL.md
  - reference/agent-skills/skills/incremental-implementation/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# implementer

## 何时调用

- `/signoff --stage=assertion` 已通过，用户说"开始实现"、"/implementer"时。
- 被 `/story` 总入口调用，且 workflow-state 的 phase 为 BUILD 时。

## 输入

- `.aiassist/stories/<id>/workflow-state.yaml`
- `.aiassist/stories/<id>/prd.md`（含 §10 技术方案、§11 测试决策；无独立 `tech-design.md`）
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/signoff.md`
- `.aiassist/stories/<id>/ux/*.html`（如有 UX 原型，作为视觉/结构参照）
- `.aiassist/stories/<id>/ux/_d_meta.json`（资产注册表 + 设计系统绑定）
- `.aiassist/stories/<id>/ux/_ds_manifest.json`（story 级组件清单与 prop 契约，如有）
- `.aiassist/global/_ds/<slug>/_ds_prompt.md`（设计系统使用提示）
- `.aiassist/global/CONTEXT.md`（统一术语与实体命名）
- `.aiassist/global/business-capabilities.md`（能力地图）
- `.aiassist/global/adr/`（已有架构决策）
- `.aiassist/global/codegraph.json`（CodeGraph 配置）
- 测试文件（项目对应位置）

## 输出

- 实现代码（由子代理写入项目源码目录）
- 一个或多个 `[build]` commit
- `.aiassist/stories/<id>/build-progress.md`（含每个 slice 的 PRD→代码 可追溯性声明）
- 更新后的 `.aiassist/stories/<id>/workflow-state.yaml`

## 默认模式：子代理调度模式

`/implementer` 的默认行为是**父代理调度 + 子代理实现**。父代理不直接写实现代码，只负责：

1. 读取并理解全局设计上下文
2. 识别/拆分切片
3. 逐个派发 implementer subagent
4. 独立验证每个子代理的产出
5. 推进到下一个切片

即使只有一个切片，也走子代理。这样可以保持实现上下文干净，父代理始终保有全局视角。

### 步骤

#### 1. 读取设计上下文（父代理）

在调度任何子代理之前，父代理必须先完整阅读：

1. `prd.md`：story 初衷、用户痛点，以及 §10 技术方案的模块边界、数据流、接口契约
2. `requirements.md`：所有 REQ-ID、验收标准、capability/entity、seam、测试路径
3. `signoff.md`：已锁定的断言范围和约束（AI 自检 + expected 可 trace；升级项人已确认）
4. `workflow-state.yaml`：当前 phase、attempt、slices、history
5. `ux/*.html`、`_d_meta.json`、`_ds_manifest.json`、`_ds_prompt.md`（如有 UX 原型）
6. `.aiassist/global/CONTEXT.md`、`business-capabilities.md`、`adr/`、`codegraph.json`

父代理应简要记录：
- 本 story 涉及哪些 capability/entity
- 各切片之间的依赖关系
- 关键接口契约和边界 case
- 与 HTML 原型的对齐要点

#### 2. 识别切片

- **优先使用** `workflow-state.yaml` 中已有的 `slices` 列表。
- **如果没有**，按 `requirements.md` 自动分组：
  - 按 capability/entity 分组；
  - 或按 area/phase 分组；
  - 每个切片包含一组相关的 REQ-ID 和对应的测试文件。
- 将切片列表写入 `build-progress.md`。

#### 3. 按依赖顺序派发 implementer subagent

对每个未完成的切片：

1. 记录 slice 开始（写入 `build-progress.md`）。
2. 使用 Agent 工具派发 implementer subagent（见下文"子代理任务简报"）。
3. 子代理返回后，父代理**必须独立验证**：
   - 亲自跑测试命令
   - 读取输出，确认业务测试全绿
   - 检查 diff 是否只包含实现代码、是否误改测试
4. 如果测试与 diff 验证通过，继续 PRD 意图对齐检查：
   - 读取子代理在 `build-progress.md` 中写入的 **PRD→代码 可追溯性表**，父代理对照 `prd.md`、`requirements.md`、当前 diff、测试文件逐项审查，确认每个 PRD 意图项都有实现文件和测试覆盖。
   - 使用 Agent 工具派发 **PRD 对齐子代理**（见下文"PRD 对齐子代理"），对抗式检查 PRD 操作流、验证规则、错误状态是否已在实现中完整表达。
   - 如果可追溯性审查或 PRD 对齐子代理发现缺口：
     - 不派发 refactor subagent，不标记 slice 完成，不进入下一个 slice。
     - 将缺口按 `/bug` 做初步分类（缺实现 / 缺测试 / PRD（含技术方案）错误等）。
     - 向用户报告 blocker，建议先补缺口（继续 `/implementer` 或回流 `/to-prd` / `/tech-design`）。
     - 停止当前 `/implementer` 调用。
5. 如果 PRD 意图对齐检查也通过：
   - 使用 Agent 工具派发 **refactor subagent**（见下文"Refactor Subagent 任务简报"），对当前 slice 做一轮安全重构。
   - refactor subagent 返回后，父代理**再次独立验证**：
     - 业务测试仍全绿
     - diff 只包含实现代码，没有误改测试或扩大范围
   - 如果 refactor 导致测试失败或 diff 超出当前 slice：要求 refactor subagent 回滚，或父代理自行回滚到 refactor 前状态。
6. 如果两次验证都通过：
   - 更新 `workflow-state`：标记该 slice 完成。
   - 在 `build-progress.md` 追加：
     ```
     Slice X: complete (<base7>..<head7>, tests green, PRD alignment passed)
     Slice X: refactor pass done (<head7>..<refactor7>, tests green, no rollback)
     ```
   - 如果 CodeGraph 已启用，运行 `codegraph sync`（失败则记录警告）。
   - 进入下一个切片。
7. 如果任一验证失败：
   - 派发 fix subagent，带上失败证据、相关 diff、测试输出。
   - 修复后重新验证。
   - 超过轮数上限仍失败 → 停止，向用户报告 blocker。

#### 4. 完成所有切片后

1. 跑 `git log --oneline` 汇总所有 `[build]` 和 `[refactor]` commit。
2. 汇报：哪些切片已完成、总测试数、是否有 concerns、是否有未处理的设计问题。
3. 推荐下一步：`/qa-runner` → `/reflect`（或先 `/bug` 处理缺陷）。
4. 不要自行合并，等待 `/reflect` 最终验收通过。

## 显式降级：当前代理自循环模式

如果用户明确说"在当前上下文实现"、"不用子代理"、"我自循环"，则父代理自己按单切片方式实现所有切片。这是降级选项，仅在以下情况使用：

- 切片之间强耦合，需要连续上下文
- 子代理成本过高或项目极小
- 用户明确要求

自循环模式下，父代理仍需先读设计上下文，然后按"子代理任务简报"中的阅读顺序和实现纪律执行。

## 子代理任务简报

使用 Agent 工具派发。prompt 必须包含：

### 1. 任务定位

- 本切片在 story 中的位置
- 本切片对应的 REQ-ID 列表
- 依赖哪些已完成的切片
- 本切片的输入、输出、涉及模块、关键契约

### 2. 强制阅读顺序（写代码前必须完成）

1. `prd.md`：本 slice 要解决的用户痛点和业务范围。
2. `requirements.md`：本切片对应的 REQ-ID、验收标准、capability/entity。
3. `prd.md` §10-11：相关模块边界、数据流、接口契约、测试 seams。
4. `signoff.md`：已锁定的断言范围和已知约束（AI 自检 + expected 可 trace；升级项人已确认）。
5. 测试文件：理解输入/输出/断言。
6. `ux/_d_meta.json` 与 `ux/*.html`：视觉/结构参照；子代理必须读取并对齐。
7. `ux/_ds_manifest.json` 与 `.aiassist/global/_ds/<slug>/_ds_prompt.md`：story 级组件清单与 prop 契约。
8. `.aiassist/global/CONTEXT.md`：统一术语。
9. `.aiassist/global/codegraph.json`：CodeGraph 配置；启用时优先查询图谱（仅作为导航辅助，不能替代读文档）。

**禁止在没读设计上下文之前就大规模探索代码或写实现。**

### 3. 增量实现纪律

每个切片都是一次 thin vertical slice。子代理在切片内必须遵守：

- **Rule 0: Simplicity First** — 写代码前先问："最简单的可行方案是什么？" 避免为假设的未来需求构建抽象。
- **Rule 0.5: Scope Discipline** — 只改任务需要的内容。不"顺手"重构相邻代码、不改无关文件语法/导入、不删除不理解的注释、不加范围外功能。发现值得改进的地方，记下来问用户，而不是当场改。
- **Rule 1: One Thing at a Time** — 一个 increment 只改一个逻辑。不要把新组件、重构、构建配置混在一个 commit。
- **Rule 2: Keep It Compilable** — 每个 increment 后项目必须能构建，现有测试必须绿。不要留下中间坏状态。
- **Rule 3: Feature Flags for Incomplete Features** — 如果功能未就绪但需要合并，用 feature flag 隐藏，避免用户看到半成品。
- **Rule 4: Safe Defaults** — 新代码默认安全、保守。例如通知默认关闭，新权限默认最小。
- **Rule 5: Rollback-Friendly** — 每个 increment 可独立回滚。优先 additive 改动，修改现有代码时尽量小范围聚焦。

### 4. 产出要求

- 只写实现代码，不修改业务测试（契约）。
- 在实现每个 seam 时使用 `/tdd` 纪律：**RED → GREEN**。
  - `/tdd` 不负责重构；深度重构在 slice 完成后由 refactor subagent 处理。
  - GREEN 阶段只允许最小清理（ obvious 坏命名、格式），不允许做结构性重构或引入新抽象。
- 单元测试是实现工具，不进入契约，不需要持久化或签核。
- 对照 HTML 原型实现视觉与结构，无法完全对齐时记录偏差。
- 实现完成后跑**全套业务测试**。
- 全部通过后再 commit；commit 消息格式：`[build] <slice 名称>`。
- **测试全绿只是最低门槛**：子代理必须确认实现同时满足 PRD 意图、`prd.md` §10 技术方案契约、UX HTML 结构/行为，不能仅为通过测试而硬凑。
- **PRD→代码 可追溯性表**：子代理必须在 `build-progress.md` 中为本 slice 写入一张表，逐条列出本 slice 涉及的 PRD 意图（操作流步骤、验证规则、错误状态、UX 结构/行为等），并给出对应的实现文件、测试文件和状态（`COVERED` / `PARTIAL` / `GAP`）。不允许全部留白或用模糊描述填充。
- **禁止以测试通过为由跳过 PRD 定义的行为**：错误状态、表单校验、分支流程、副作用/回滚必须按 PRD 实现，不能因现有测试未覆盖就忽略。
- 如果 CodeGraph 已启用，commit 后运行 `codegraph sync` 更新图谱。

### 5. 报告要求

子代理返回：

- 状态：`DONE` / `DONE_WITH_CONCERNS` / `BLOCKED`
- 修改的文件列表
- 测试命令和输出摘要（证明业务测试全绿）
- **PRD→代码 可追溯性表（已写入 `build-progress.md`）**
- 与 HTML 原型的已知偏差
- commit hash
- 任何 concerns

## Refactor Subagent

在每个 slice 的业务测试全绿后，`/implementer` 父代理派发 refactor subagent，用相对新鲜的上下文做一轮安全重构。这是为了解决"AI 在同一会话中偏爱自己刚写代码"的确认偏见问题。

### 任务简报

使用 Agent 工具派发。prompt 必须包含：

#### 1. 任务定位

- 本 slice 在 story 中的位置、对应的 REQ-ID 列表。
- 本 slice 已修改的文件列表（严格范围锁）。
- 原始 diff（重构前的状态）。
- `requirements.md` 和 `prd.md` §10-11 中相关契约。
- `.aiassist/global/checklists/testing.md` 作为测试纪律参考。

#### 2. 输入读取顺序

1. `requirements.md`：本 slice 对应的 REQ-ID、验收标准。
2. `prd.md` §10：相关模块边界、数据流、接口契约。
3. 当前 slice 的 diff。
4. `.aiassist/global/checklists/testing.md`。

#### 3. 重构纪律

- **只做一轮**：输出报告后停止，不循环审视。
- **范围锁**：只允许修改本 slice 已变更的文件；不允许顺手重构相邻代码、不删除不理解的注释、不改无关导入。
- **只允许安全重构**：
  - ✅ 重命名变量/函数/类以提高清晰度
  - ✅ 提取当前 diff 内的重复逻辑为 helper
  - ✅ 简化明显过长或嵌套过深的函数
  - ✅ 消除当前 diff 内明显的代码异味
  - ❌ 改变 public 接口契约
  - ❌ 改变行为或引入新行为
  - ❌ 引入未经验证的新抽象
  - ❌ 修改业务测试文件
- **保持可构建、可测试**：每个小重构后项目必须能构建，相关测试必须绿。
- **测试约束**：重构完成后必须跑**全套业务测试 + 相关单元测试**。如果任何测试变红，**立即回滚到 refactor 前状态**并报告 `ROLLED_BACK`。
- **commit 要求**：如果有修改且测试全绿，提交 `[refactor] <slice 名称>`；如果没有修改，报告 `NO_CHANGES_NEEDED`。

#### 4. 输出要求

子代理返回：

- 状态：`REFACTORED` / `NO_CHANGES_NEEDED` / `ROLLED_BACK`
- 修改的文件列表（如有）
- 每项重构的简短理由
- 发现但未处理的设计问题（留给 `/review --cover=code` 或人决策）
- 测试命令和输出摘要（证明重构后测试仍绿）
- 原始 commit hash 与新的 commit hash（如有）

### 父代理验证

refactor subagent 返回后，父代理必须：

1. 再次跑全套业务测试，确认仍全绿。
2. 检查 diff：
   - 只允许修改实现代码，不允许碰业务测试。
   - 不允许超出当前 slice 原始修改范围。
3. 如果验证失败：
   - 要求 refactor subagent 回滚，或父代理直接 `git revert` 到 refactor 前。
   - 记录回滚原因到 `build-progress.md`。
   - 标记 slice 仍视为"业务测试绿"状态，但不接受该 refactor。

## Fix Subagent

当父代理验证子代理产出失败时，或 `/bug` 调用时，派发 fix subagent。

### 普通修复（BUILD 阶段验证失败）

- 带上失败证据：测试命令、输出片段、失败测试名
- 带上相关 diff
- 带上原任务简报
- 要求：修复失败，跑全套业务测试，返回新 commit hash

### Bug 修复（由 `/bug` 调用）

fix subagent 的任务简报还必须包含 bug 上下文：

- bug 上下文（由 `/bug` 在会话中传入）：症状、复现步骤、根因假设、关联 REQ-ID
- 回归测试路径：必须能在修复前失败、修复后通过
- 修复范围：只修改实现代码，不修改业务测试契约
- commit 消息格式：`[bugfix] BUG-NNN: <summary>`

fix subagent 在 bug 修复中：
- 先读 bug 上下文和回归测试，确认理解失败场景。
- 用 `/tdd` 纪律写最小实现让回归测试通过。
- 跑全套业务测试，确保没有回归。
- 禁止顺手重构相邻代码（重构走 refactor subagent）。
- 返回修复摘要、修改文件、新 commit hash。

实际项目中使用 `CLAUDE.md` 或项目约定中的测试命令。示例：

```bash
npm test
# 或
pytest
# 或
./run-tests.sh
```

## PRD 对齐子代理

`/implementer` 父代理在每个 slice 的**业务测试全绿且 diff 验证通过后**，必须派发 PRD 对齐子代理，用相对独立的上下文做一轮对抗式 PRD 意图检查。这是为了捕捉"测试通过但 PRD 错误状态/验证/分支未实现"的偏差。

### 任务简报

使用 Agent 工具派发。prompt 必须包含：

#### 1. 任务定位

- 本 slice 在 story 中的位置、对应的 REQ-ID 列表。
- 本 slice 声称覆盖的 PRD 意图项（来自 `build-progress.md` 中的 PRD→代码 可追溯性表）。
- 当前 slice 的 diff（实现代码）。
- 本 slice 涉及的业务测试文件路径。
- `prd.md` 第 6-8 节相关条目（操作流、验证规则、错误状态）。

#### 2. 输入读取顺序

1. `prd.md`：重点读第 6-8 节，明确本 slice 应实现的 PRD 意图。
2. `requirements.md`：本 slice 对应的 REQ-ID、验收标准。
3. `prd.md` §10：相关模块边界、数据流、接口契约。
4. 当前 slice 的 diff（实现代码）。
5. 相关业务测试文件。
6. `build-progress.md` 中的 PRD→代码 可追溯性表（子代理此前写入）。

#### 3. 检查维度

- **操作流完整性**：PRD 第 6 节的 happy path 步骤和分支/异常是否都在实现中有对应路径？是否遗漏分支触发条件或结果？
- **验证规则完整性**：PRD 第 7 节的字段级验证、跨字段/业务规则是否在实现中执行？错误提示、触发时机、错误状态是否与 PRD 一致？
- **错误状态完整性**：PRD 第 8 节的失败场景（含外部依赖/网络/权限/超时等）是否在实现中处理？错误码/消息、用户可见状态、副作用/回滚是否与 PRD 一致？
- **UX 结构/行为一致性**：如涉及 `ux/*.html`，检查关键元素、状态变化、导航流程是否与 PRD 意图一致；偏差是否有显式记录。
- **可追溯性表真实性**：检查表中列出的"实现文件"和"测试文件"是否真实存在、是否确实覆盖对应 PRD 意图；不允许根据假设填充。

#### 4. 输出要求

子代理返回：

- 状态：`ALIGNED` / `MISALIGNMENT_FOUND` / `UNCERTAIN`
- 对齐项清单（逐条说明 PRD 意图 → 实现文件 → 测试覆盖，状态为 `COVERED`）
- 缺口项清单（PRD 意图 → 发现的问题 → 建议分类）
  - 分类建议：`missing-implementation`（实现漏了）、`missing-test`（测试没覆盖但实现可能有）、`prd-error`（PRD 自身矛盾或不清晰）、`spec-gap`（prd.md §10/§11 缺 seam 或契约）
- 任何 `UNCERTAIN` 项必须说明需要人确认什么

### 父代理处理

PRD 对齐子代理返回后，父代理必须：

1. 阅读对齐报告，确认缺口是否真实。
2. 若状态为 `ALIGNED`：允许进入 refactor subagent 阶段。
3. 若状态为 `MISALIGNMENT_FOUND`：
   - 不标记 slice 完成，不进入 refactor，不进入下一个 slice。
   - 按缺口分类建议，选择继续由 `/implementer` 补实现、`/test-author` 补测试，或回流 `/to-prd` / `/tech-design`。
   - 若缺口是具体可定位的代码缺陷，也可转 `/bug` 处理。
   - 将缺口和处理决定记录到 `build-progress.md`。
4. 若状态为 `UNCERTAIN`：向用户展示不确定项，请人确认后再决定。

## 纪律

- **父代理不写实现代码**：父代理只读文档、调度、验证、更新元数据。
- **写代码前必须先读设计上下文**：`prd.md`（含技术方案）→ `requirements.md` → `signoff.md` → 测试 → UX HTML。禁止没读文档就探索代码或写实现。
- **对业务测试只读**：禁止修改由 `/test-author` 生成、已签核锁定的业务测试文件。
- **单元测试是 TDD 工具**：子代理可在实现过程中自由写、改、删单元测试，它们不进入契约。
- **diff 碰业务测试 = 本轮作废**。
- **每轮跑全套业务测试**：停机条件是"全套业务测试绿"，但绿只是最低门槛。
- **测试全绿 ≠ 实现正确**：绿了之后必须对照 PRD（含技术方案）、UX HTML 检查意图是否完整实现。禁止为绿而写特判、mock 掉真实行为、或阉割功能。
- **PRD 意图对齐是 slice 完成的必要条件**：只有 PRD 对齐子代理报告 `ALIGNED`，slice 才能标记完成。
- **不擅自放宽断言**。
- **不跳过看起来"无关"的失败**。
- **HTML 原型是参照不是规范**：实现时尽量对齐 HTML 原型，但偏差必须显式记录，不能悄悄忽略。
- **自动模式下不合并切片 commit**：每个切片独立 commit，便于回滚和审查。
- **验证不能省**：子代理说完成不算，父代理必须亲自跑测试确认。
- **业务测试优先**：如果单元测试和业务测试冲突，业务测试优先。
- **CodeGraph 是导航辅助**：启用时优先查询图谱理解模块关系，但必须以实际代码语义为准；不可用时回退 grep/read。
- **CodeGraph 同步**：每个 slice 实现完成并提交后，如启用则运行 `codegraph sync`，保持图谱与代码一致。
- **遵循 CONTEXT.md 术语**：实现中的实体/模块命名与全局领域词汇表保持一致。
- **每个 slice 必须留下 PRD→代码 可追溯性声明**：`build-progress.md` 中的表格是后续 `/signoff`（BUILD 后复查）和 `/reflect` 人工验收的输入。

## 与参考项目的差异

- superpowers `subagent-driven-development`：给我们子代理批量执行、任务简报、审查包和进度 ledger。
- superpowers `executing-plans`：给我们按计划连续执行的模式。
- superpowers `verification-before-completion`：给我们"证据先于完成声明"的纪律。
- superpowers `finishing-a-development-branch`：给我们全部任务完成后的收尾思路。
- mattpocock `implement`：给我们"按已有上下文实现"的轻量模式。
- 核心差异：默认使用子代理实现每个切片，父代理专职调度与验证；测试只读 + 断言可 trace 到规格锚点 + 轮数上限逃生口 + TAC 的两道门。

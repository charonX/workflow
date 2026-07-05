---
name: tac-implementer
description: 在测试契约内自主实现代码。支持单切片模式与自动连续模式，可按顺序独立完成多个切片，每个切片一个 commit，对测试只读。
sources:
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
  - reference/superpowers/skills/executing-plans/SKILL.md
  - reference/superpowers/skills/verification-before-completion/SKILL.md
  - reference/superpowers/skills/finishing-a-development-branch/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - reference/mattpocock/skills/engineering/implement/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# implementer

## 何时调用

- `/tac-signoff --stage=assertion` 已通过，用户说"开始实现"、"/tac-implementer"时。
- 被 `/tac-story` 总入口调用，且 workflow-state 的 phase 为 BUILD 时。

## 输入

- `.aiassist/stories/<id>/workflow-state.yaml`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/tech-design.md`（如有）
- `.aiassist/stories/<id>/signoff.md`
- `.aiassist/stories/<id>/ux/*.html`（如有 UX 原型，作为视觉/结构参照）
- 测试文件（项目对应位置，如 `*Tests/**/*.swift`、`test/**/*.test.ts` 等）
- 可选：workflow-state 中的 `slices` / `tasks` 列表

## 输出

- 实现代码（项目源码目录）
- 一个或多个 `[tac-build]` commit
- 每轮迭代报告（隐式）
- `.aiassist/stories/<id>/build-progress.md`（自动连续模式下）

## 执行模式选择

实现开始前，先判断 story 是否包含多个切片。

1. 读取 `workflow-state.yaml`。
2. 如果其中明确有 `slices` 或 `tasks` 列表，且剩余未完成的切片数 > 1，向用户呈现选择：
   - **A. 子代理连续模式**：每个切片派一个独立子代理实现，当前代理只负责调度、验证和推进。上下文最干净，适合长距离开发。
   - **B. 当前代理自循环模式**：当前代理依次完成所有切片，不派子代理。适合切片之间强耦合、需要连续上下文的情况。
   - **C. 手动单切片模式**（默认）：只实现当前切片，完成后停下来，由 `/tac-story` 决定下一步。
3. 如果用户未指定且只有 1 个切片，默认进入单切片模式。
4. 如果用户说"自动完成"、"全部做完"、"用子代理实现全部"，默认进入子代理连续模式。

选择 A 或 B 后，进入**自动连续模式**。

## 单切片模式

与原有行为一致，但增加 HTML 原型参照：

1. **读取测试**：理解每个测试的输入、输出、断言。
2. **读取 HTML UX 原型**：如果 `ux/` 目录存在，读取所有 `.html` 文件，作为视觉与结构参照。记录：
   - 页面/组件层级和命名。
   - 关键元素及其顺序（按钮、表单、列表、空态等）。
   - 交互状态（loading、empty、error、success、disabled）。
   - 与 `tokens.css` / `DESIGN.md` 关联的样式 token。
   实现时尽量对齐；实现后记录已知偏差。
3. **内循环实现**：
   - 写最小实现使某个测试变绿。
   - 跑 **全套单元测试**（不是只跑当前测试）。
   - 如果回归失败，先修回归。
   - 重复直到全绿。
4. **轮数上限**：超过 N 轮（默认 10 轮）仍未全绿，停止并升级。
5. **升级策略**：
   - "我实现不出来，诊断如下" → 升级给人/更强模型。
   - "我怀疑断言 X 自相矛盾/不可满足，证据如下" → 回 `/tac-signoff --stage=assertion`。
6. **偏差记录**：提交前输出一段简短说明，列出实现与 HTML 原型的已知偏差（如无法直接复刻的动画、平台限制导致的布局差异）。
7. **提交**：全绿后提交，commit 消息使用 `[tac-build]` 标签。一个 commit 只包含实现代码，不能包含测试文件。

## 自动连续模式

目标：在**断言一次性签核**的前提下，AI 连续独立完成所有剩余切片，每个切片一个 `[tac-build]` commit。

### 前置检查

1. **识别切片**：
   - 优先读取 `workflow-state.yaml` 里的 `slices` 或 `tasks` 列表。
   - 如果没有，按 `requirements.md` 中的 REQ-ID 分组，把每个稳定块作为一个切片。
2. **检查断言签核**：
   - 所有切片对应的测试文件必须存在且已被 `signoff.md` 覆盖。
   - 如果还有未签核的切片：
     - 对每个未签核切片调用 `/tac-test-author` 生成测试骨架。
     - 汇总所有测试清单，请用户**一次性批量签核**。
     - 签核完成后才进入实现循环。
3. **建立进度账本**：创建/读取 `.aiassist/stories/<id>/build-progress.md`，记录每个切片的 base commit、head commit、状态。

### 切片执行循环

按依赖顺序处理每个未完成的切片：

```
for slice in remaining_slices:
    1. 记录 slice 开始
    2. 根据模式执行：
       - 子代理模式：派发 implementer subagent（见下文"子代理任务简报"）
       - 自循环模式：当前代理按"单切片模式"实现
    3. 独立验证：
       - 子代理报告"完成后"，父代理必须亲自跑测试命令，读取输出，确认全绿。
       - 参考 superpowers verification-before-completion：没有验证证据就不能声称完成。
    4. 如果通过：
       - 更新 workflow-state：标记该 slice 完成。
       - 在 build-progress.md 追加：`Slice X: complete (<base7>..<head7>, tests green)`
       - 进入下一个切片。
    5. 如果失败：
       - 子代理模式：派发 fix subagent，带上失败证据和完整 diff。
       - 自循环模式：当前上下文修复。
       - 修复后重新验证。
       - 超过轮数上限仍失败 → 停止，向用户报告 blocker。
```

### 子代理任务简报

使用 Agent 工具派发。prompt 必须包含：

1. **任务定位**：这个切片在 story 中的位置，依赖哪些已完成的切片。
2. **输入文件路径**：
   - `requirements.md`（指出本切片对应的 REQ-ID）
   - `tech-design.md`（相关模块/数据流/seams）
   - `ux/*.html`（视觉/结构参照；子代理必须读取并对齐）
   - 测试文件路径
   - `signoff.md`
3. **产出要求**：
   - 只写实现代码，不修改测试。
   - 对照 HTML 原型实现视觉与结构，无法完全对齐时记录偏差。
   - 实现完成后跑**全套单元测试**。
   - 全部通过后再 commit。
   - commit 消息格式：`[tac-build] <slice 名称>`。
4. **报告要求**：子代理返回：
   - 状态：`DONE` / `DONE_WITH_CONCERNS` / `BLOCKED`
   - 修改的文件列表
   - 测试命令和输出摘要
   - 与 HTML 原型的已知偏差
   - commit hash
   - 任何 concerns

### 当前代理自循环

与单切片模式相同，只是完成后不退出，而是：

1. 更新 `build-progress.md`。
2. 读取 workflow-state，找到下一个切片。
3. 继续。

### 完成所有切片后

1. 跑 `git log --oneline` 汇总所有 `[tac-build]` commit。
2. 汇报：哪些切片已完成、总测试数、是否有 concerns。
3. 推荐下一步：`/tac-qa-runner` → `/tac-signoff --stage=feel`。
4. 不要自行合并，等待 `/tac-signoff --stage=feel` 通过。

## 内循环命令

```bash
cd /Users/zhanglei/charon/code/workspace/BanshanJourney
xcodebuild -project BanshanJourney.xcodeproj -scheme BanshanJourneyTests -destination 'platform=iOS Simulator,name=iPhone 17' test 2>&1 | grep -E "(Test Suite|Executed|failures)"
```

预期输出：`Executed N tests, with 0 failures (0 unexpected)`

实际项目中使用 `CLAUDE.md` 或项目约定中的测试命令。

## 纪律

- **对测试只读**：禁止修改任何测试文件。
- **diff 碰测试 = 本轮作废**。
- **每轮跑全套单元**：停机条件是"全套绿"。
- **不擅自放宽断言**。
- **不跳过看起来"无关"的失败**。
- **HTML 原型是参照不是规范**：实现时尽量对齐 HTML 原型，但偏差必须显式记录，不能悄悄忽略。
- **自动模式下不合并切片 commit**：每个切片独立 commit，便于回滚和审查。
- **验证不能省**：子代理说完成不算，父代理必须亲自跑测试确认。

## 与参考项目的差异

- superpowers `subagent-driven-development`：给我们子代理批量执行、任务简报、审查包和进度 ledger。
- superpowers `executing-plans`：给我们按计划连续执行的模式。
- superpowers `verification-before-completion`：给我们"证据先于完成声明"的纪律。
- superpowers `finishing-a-development-branch`：给我们全部任务完成后的收尾思路。
- mattpocock `implement`：给我们"按已有上下文实现"的轻量模式。
- 核心差异：测试只读 + 断言归人 + 轮数上限逃生口 + TAC 的两道门（`/tac-signoff --stage=assertion` 批量签、`/tac-signoff --stage=feel` 最后统一过）。

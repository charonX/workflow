---
name: signoff
description: 外层设计循环的终点（门 1）。断言签核默认由 AI 全量自检完成，把契约交给 AI 实现；仅在升级点（初衷漂移、跨模块契约歧义、expected 推导不出、安全边界、范围决策）停下由人确认。
sources:
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/gstack/design-review/SKILL.md
  - reference/gstack/plan-design-review/SKILL.md
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# signoff

## 何时调用

- `/test-author` 完成后，进入 BUILD 前：`/signoff --stage=assertion`。
- 由 `/story` 自动链调用：作为 CRYSTALLIZE→TEST→ASSERTION-SIGNOFF 的收尾段，AI 自动签核，仅升级点停下。

## 输入

- `--stage`：必填，仅支持 `assertion`
- `--story`：可选，story-id
- 阶段相关文件（见下文）

## 输出

- `.aiassist/stories/<id>/signoff.md`（Assertion section，signer 字段：AI / human）
- assertion 阶段产生 `[test] assertion-signoff for <story-id>` commit
- 更新 `workflow-state.yaml`：`phase: BUILD`（解锁实现）

## assertion 阶段

### 输入

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/test-plan.md`
- `.aiassist/global/business-capabilities.md`（检查能力覆盖）
- `.aiassist/global/CONTEXT.md`（统一术语）
- 测试文件（含 `// EXPECTED-TRACE` 标注）
- `.aiassist/stories/<id>/prd.md`（§6.3/§7/§10.4 预期值锚点，trace 交叉验证的基准）

### 执行步骤

1. **确认 PRD 缺口已归类**：读 `prd.md` §14 自检查表，每个 GAP 必须有明确去处——就地补 / 移动块（§5）/ 新建 story / 范围外（§12），**不允许悬空**。范围决策（新建 story / 范围外）命中升级点，停下与用户确认归类。
2. **AI 全量自检（默认执行，结果写入 signoff.md）**：
   - 每个 REQ-ID 至少有一个测试。
   - 每个测试文件有 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`、`EXPECTED-TRACE`。
   - **expected 值交叉验证**：逐条核对 `// EXPECTED-TRACE` 标注的锚点真实存在于 `prd.md`（§6.3/§7/§10.4）且值一致。
   - capability/entity 与 `business-capabilities.md` 一致。
   - 无 `// TODO: HUMAN ASSERTION` 占位（未解决升级点除外）。
   - 无快照当判定依据。
   - 边界/错误 case 已覆盖。
3. **升级点检查（按需，命中才停下问人）**：
   - **初衷漂移信号**：story `intention` ↔ PRD §1 问题陈述 ↔ REQ 集合是否一致；不一致 → 升级。
   - **跨模块契约歧义**：§10.4 契约无法从 PRD 锚点确认 → 升级。
   - **expected trace 失败**：某条断言 expected 值无法 trace 到 PRD 锚点或 bug 分类记录，且 `// TODO: HUMAN ASSERTION` 存在 → 升级让人拍值（就地补 PRD 或确认 expected）。
   - **安全边界**（如有涉及）：涉及信任边界/资产 → 升级确认威胁建模。
   - **范围决策**：GAP 归类为新建 story / 范围外 → 升级。
   无升级项 → 零打断，直接签核。
4. **展示给用户**：先给"升级点结果（如有）"，再给"AI 自检结果摘要"（供抽查；`auto` 签核时用户扫一眼确认，不必逐项）。
5. **生成/更新 signoff 文件**：填写 `signoff.md` 中 Assertion 部分的 REQ-ID 列表、capability/entity 覆盖摘要、断言摘要、expected trace 摘要，以及 signer 字段（无升级 = `AI`；升级后人确认 = `human`）。有升级点时记录升级点表格。
6. **提交签核 commit**：
   ```bash
   git add .aiassist/stories/<id>/signoff.md
   git commit -m "[test] assertion-signoff for <story-id>"
   ```
7. **更新 workflow-state**：`phase: BUILD`，解锁实现。

### 检查清单

**A. 升级点（按需，命中才停下问人）**

- [ ] PRD §1 初衷（问题陈述）仍是用户痛点，未漂移（有漂移信号 → 升级）。
- [ ] 跨模块 REQ 的接口契约（§10.4）可从 PRD 锚点确认，无歧义（有歧义 → 升级）。
- [ ] 所有断言的 expected 值均可 trace（存在未解决 `// TODO: HUMAN ASSERTION` → 升级让人拍值）。
- [ ] 安全边界（如涉及）已确认。
- [ ] PRD §14 每个 GAP 已归类（就地补 / 移动块 / 新建 story / 范围外），无悬空；范围决策 → 升级。

**B. AI 全量自检（默认执行，写入 signoff.md）**

- [ ] 每个 REQ-ID 都有对应测试。
- [ ] 每个测试文件都有 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`、`EXPECTED-TRACE`。
- [ ] 每条 `// EXPECTED-TRACE` 锚点真实存在于 `prd.md` 且值一致（交叉验证）。
- [ ] 每个 REQ 的 capability/entity 与 `business-capabilities.md` 一致。
- [ ] 无 `// TODO: HUMAN ASSERTION` 占位（未解决升级点除外）。
- [ ] 无快照当判定依据。
- [ ] 边界/错误 case 已覆盖。
- [ ] `signoff.md` Assertion 部分已创建，`phase: BUILD` 已写入，并通过 `[test] assertion-signoff for <story-id>` commit 提交。

> BUILD 完成后，父代理将再次检查 `build-progress.md` 中的 PRD-to-code 可追溯性声明。

## 纪律

- **assertion 不通过禁止 BUILD**（自动签核通过即算通过）。
- 签核 commit 记录契约锁定：expected 值可 trace 到 PRD 锚点（人定锚点），升级项由人确认。**人对规格锚点承担最终责任**；`auto` 签核下 AI 对推导与交叉验证负责。
- assertion 阶段签核 commit 只应修改 `signoff.md`，不应同时修改测试文件或实现代码。
- **PRD §14 的 GAP 必须显式归类**（补/移动块/新 story/范围外），不能静默带入 BUILD；范围决策必须升级给人。
- **expected 值交叉验证是反作弊底线**：任何断言 expected 值若无法 trace 到 PRD 锚点或 bug 分类记录，必须就地补 PRD 或升级，不得静默放行。

## 与参考项目的差异

- gstack `plan-eng-review` / `design-review` 被收窄为断言签核门。
- mattpocock `tdd` 强调测试先行；我们升级为"断言可 trace 到人定的规格锚点才算契约"。
- 核心差异：用 Git commit 替代手写签名，签核证据更可靠；signoff 从"人逐项签高风险"演进为"AI 全量自检 + 按需升级"，assertion 阶段同时检查 capability/entity 覆盖，确保 story 测试接入长期业务能力资产。

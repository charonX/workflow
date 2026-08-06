---
name: signoff
description: 外层设计循环的终点（门 1）。人在实现前签核高风险断言（初衷、跨模块契约、expected 值、安全边界），其余由 AI 自检，把契约交给 AI 实现。
sources:
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/gstack/design-review/SKILL.md
  - reference/gstack/plan-design-review/SKILL.md
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# signoff

## 何时调用

- `/test-author` 完成后，进入 BUILD 前：`/signoff --stage=assertion`

## 输入

- `--stage`：必填，仅支持 `assertion`
- `--story`：可选，story-id
- 阶段相关文件（见下文）

## 输出

- `.aiassist/stories/<id>/signoff.md`（Assertion section）
- assertion 阶段产生 `[test] assertion-signoff for <story-id>` commit
- 更新 `workflow-state.yaml`，标记 assertion-signoff 通过，解锁 BUILD

## assertion 阶段

### 输入

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/test-plan.md`
- `.aiassist/global/business-capabilities.md`（检查能力覆盖）
- `.aiassist/global/CONTEXT.md`（统一术语）
- 测试文件

### 执行步骤

1. **确认 PRD 缺口已归类**：读 `prd.md` §14 自检查表，每个 GAP 必须有明确去处——就地补 / 移动块（§5）/ 新建 story / 范围外（§12），**不允许悬空**。若有未归类 GAP，先与用户确认归类，再继续。
2. **AI 自检（全量，结果写入 signoff.md 供人抽查）**：
   - 每个 REQ-ID 至少有一个测试。
   - 每个测试文件有 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`。
   - capability/entity 与 `business-capabilities.md` 一致。
   - 无 `// TODO: HUMAN ASSERTION` 占位。
   - 无快照当判定依据。
   - 边界/错误 case 已覆盖。
3. **人确认（高风险，逐项）**：
   - **初衷锚定**：`prd.md` §1 问题陈述仍是用户痛点。
   - **跨模块接口契约**：§10.4 的契约（输入/输出/业务错误/系统错误/副作用）准确。
   - **expected 值来源**：人手算 / 真实 JSON / 已签标准，而非代码输出。
   - **安全边界**（如有涉及）。
   - **每个 GAP 的去处**（步骤 1 结果）。
4. **展示给用户**：先给"人确认高风险清单"，再给"AI 自检结果摘要（供抽查）"。
5. **生成/更新 signoff 文件**：填写 `signoff.md` 中 Assertion 部分的 REQ-ID 列表、capability/entity 覆盖摘要、断言摘要，以及"人确认 / AI 自检"两段结果。
6. **提交签核 commit**：用户确认后，执行：
   ```bash
   git add .aiassist/stories/<id>/signoff.md
   git commit -m "[test] assertion-signoff for <story-id>"
   ```
7. **更新 workflow-state**：标记 assertion-signoff 通过，解锁 BUILD。

### 检查清单

**A. 人确认（高风险项，逐项勾选）**

- [ ] PRD §1 初衷（问题陈述）仍是用户痛点，未漂移。
- [ ] 跨模块 REQ 的接口契约（§10.4）准确：输入 / 输出 / 业务错误 / 系统错误 / 副作用。
- [ ] expected 值来源清晰（人手算 / 已签标准 / 真实 JSON），非代码输出。
- [ ] 安全边界（如涉及）已确认。
- [ ] PRD §14 每个 GAP 已归类（就地补 / 移动块 / 新建 story / 范围外），无悬空。

**B. AI 自检（写入 signoff.md，人抽查）**

- [ ] 每个 REQ-ID 都有对应测试。
- [ ] 每个测试文件都有 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`。
- [ ] 每个 REQ 的 capability/entity 与 `business-capabilities.md` 一致。
- [ ] 无 `// TODO: HUMAN ASSERTION` 占位。
- [ ] 无快照当判定依据。
- [ ] 边界/错误 case 已覆盖。
- [ ] `signoff.md` Assertion 部分已创建并通过 `[test] assertion-signoff for <story-id>` commit 提交。

> BUILD 完成后，父代理将再次检查 `build-progress.md` 中的 PRD-to-code 可追溯性声明。

## 纪律

- **assertion 不通过禁止 BUILD**。
- 签核 commit 即视为人对"什么算对"承担最终责任。
- assertion 阶段签核 commit 只应修改 `signoff.md`，不应同时修改测试文件或实现代码。
- **PRD §14 的 GAP 必须显式归类**（补/移动块/新 story/范围外），不能静默带入 BUILD。

## 与参考项目的差异

- gstack `plan-eng-review` / `design-review` 被收窄为断言签核门。
- mattpocock `tdd` 强调测试先行；我们升级为"人签测试才算契约"。
- 核心差异：用 Git commit 替代手写签名，签核证据更可靠；assertion 阶段同时检查 capability/entity 覆盖，确保 story 测试接入长期业务能力资产。

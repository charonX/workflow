---
name: signoff
description: 外层设计循环的终点（门 1）。人在实现前签核所有断言，把契约交给 AI 实现。
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

1. **扫描 REQ 覆盖**：每个 REQ-ID 是否至少有一个测试？
2. **扫描测试头部**：每个测试文件是否有 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`？
3. **扫描 capability/entity 覆盖**：根据 `business-capabilities.md`，检查本次 REQ 是否覆盖了计划中的能力/实体；新增 capability/entity 是否已在能力地图中登记。
4. **扫描占位符**：是否还有 `// TODO: HUMAN ASSERTION`？
5. **审查预期值来源**：向用户确认每个关键预期值是人算/真实 JSON/已签标准，而非代码输出。
6. **展示检查清单**：让用户逐项确认。
7. **生成/更新 signoff 文件**：填写 `signoff.md` 中 Assertion 部分的 REQ-ID 列表、capability/entity 覆盖摘要和断言摘要，确保所有检查清单项已勾选。
8. **提交签核 commit**：用户确认后，执行：
   ```bash
   git add .aiassist/stories/<id>/signoff.md
   git commit -m "[test] assertion-signoff for <story-id>"
   ```
9. **更新 workflow-state**：标记 assertion-signoff 通过，解锁 BUILD。

### 检查清单

- [ ] 每个 REQ-ID 都有对应测试。
- [ ] 每个测试文件都有 `REQ-TRACE`、`REQ-VERSION`、`CAPABILITY-TRACE`、`ENTITY-TRACE`。
- [ ] 每个 REQ 的 capability/entity 与 `business-capabilities.md` 一致。
- [ ] 无 `// TODO: HUMAN ASSERTION` 占位。
- [ ] 预期值来源清晰，非代码输出。
- [ ] 无快照当判定依据。
- [ ] 边界/错误 case 已覆盖。
- [ ] `signoff.md` Assertion 部分已创建并通过 `[test] assertion-signoff for <story-id>` commit 提交。

## 纪律

- **assertion 不通过禁止 BUILD**。
- 签核 commit 即视为人对"什么算对"承担最终责任。
- assertion 阶段签核 commit 只应修改 `signoff.md`，不应同时修改测试文件或实现代码。

## 与参考项目的差异

- gstack `plan-eng-review` / `design-review` 被收窄为断言签核门。
- mattpocock `tdd` 强调测试先行；我们升级为"人签测试才算契约"。
- 核心差异：用 Git commit 替代手写签名，签核证据更可靠；assertion 阶段同时检查 capability/entity 覆盖，确保 story 测试接入长期业务能力资产。

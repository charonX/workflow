---
name: tac-assertion-signoff
description: 断言签核门：确保所有断言都已被人签字，且预期值来源清晰，然后才允许进入 BUILD。
disable-model-invocation: true
sources:
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/mattpocock/skills/engineering/tdd/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# assertion-signoff

## 何时调用

`/tac-test-author` 完成，用户说"签断言"、`/tac-assertion-signoff` 时。

## 输入

- `.aiassist/stories/<id>/requirements.md`
- `BanshanJourneyTests/**/*.swift`
- `.aiassist/stories/<id>/test-plan.md`

## 输出

- `.aiassist/stories/<id>/tac-assertion-signoff.md`

## 执行步骤

1. **扫描 REQ 覆盖**：每个 REQ-ID 是否至少有一个测试？
2. **扫描测试头部**：每个测试文件是否有 `REQ-TRACE` 和 `REQ-VERSION`？
3. **扫描占位符**：是否还有 `// TODO: HUMAN ASSERTION`？
4. **审查预期值来源**：向用户确认每个关键预期值是人算/真实 JSON/已签标准，而非代码输出。
5. **展示检查清单**：让用户逐项确认。
6. **生成 signoff 文件**：用户签名后写入 `assertion-signoff.md`。
7. **更新 workflow-state**：标记 assertion-signoff 通过，解锁 BUILD。

## 检查清单

- [ ] 每个 REQ-ID 都有对应测试。
- [ ] 每个测试文件都有 `REQ-TRACE` 和 `REQ-VERSION`。
- [ ] 无 `// TODO: HUMAN ASSERTION` 占位。
- [ ] 预期值来源清晰，非代码输出。
- [ ] 无快照当判定依据。
- [ ] 边界/错误 case 已覆盖。
- [ ] `assertion-signoff.md` 已创建并提交。

## 纪律

- **不通过则禁止 BUILD**。
- 如果发现断言有问题，回退到 `/tac-crystallize` 或 `/tac-test-author`；绝不直接让实现者改测试。
- 用户签字 = 人对"什么算对"承担最终责任。

## 与参考项目的差异

- gstack `plan-eng-review` 是工程审查门；我们把它收窄为"断言签核门"（`/tac-assertion-signoff`）。
- mattpocock `tdd` 强调测试先行；我们把它升级为"人签测试才算契约"。

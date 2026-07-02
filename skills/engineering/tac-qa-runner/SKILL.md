---
name: tac-qa-runner
description: 慢外门 QA：跑 E2E 测试、回归测试，收集证据，输出 QA 报告。
sources:
  - reference/gstack/qa/SKILL.md
  - reference/gstack/qa-only/SKILL.md
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# qa-runner

## 何时调用

BUILD 阶段全单元绿，进入 REVIEW/QA 慢外门时。或被 `/tac-story` 总入口调用。

## 输入

- 实现代码
- `BanshanJourneyTests/**/*.swift`
- `BanshanJourneyUITests/**/*.swift`（如有）
- `.aiassist/stories/<id>/requirements.md`

## 输出

- `.aiassist/stories/<id>/qa-report.md`
- 截图/日志证据（可选）

## 执行步骤

1. **跑单元测试**：确认仍全绿。
2. **跑 E2E/UITests**：验证关键用户流程。
3. **手动模拟器验证**：启动 app，走一遍核心流程。
4. **记录不稳定测试**：绿红不定的测试单独标记，开不稳定问题单。
5. **输出 QA 报告**：
   - 哪些 REQ 被验证
   - 哪些失败
   - 不稳定测试列表
   - 建议下一步（feel-signoff / 回 BUILD / 回 REQ）

## QA 报告模板

```markdown
# QA 报告 — <story-id>

## 单元测试
- 结果：PASS / FAIL
- 命令输出：...

## E2E/UITests
- 结果：PASS / FAIL
- 失败详情：...

## 手动验证
- 环境：iPhone 17 Simulator, iOS 26
- 结果：...
- 截图：...

## 不稳定测试
| 测试名 | 现象 | 处理 |
|---|---|---|
| ... | 时绿时红 | 已开单，限时修 |

## 结论
- [ ] 可进入 feel-signoff
- [ ] 需回 BUILD
- [ ] 需回 REQ
```

## 纪律

- 行为对错由测试判；观感好坏留给 feel-signoff 人判。
- 不稳定测试不掩盖：默认放行但开限时单；反复时绿时红到阈值转阻断。
- 不自动修不稳定 E2E；疑似产品竞态则回 assertion-signoff/REQ。

## 与参考项目的差异

- gstack `qa` 强调健康分和差异感知测试；我们采用更轻量的报告模板。
- superpowers 给我们专家子代理审查模式，可扩展为并行 QA。

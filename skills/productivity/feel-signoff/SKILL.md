---
name: feel-signoff
description: 观感签核门：人对照 HTML UX 参照验证观感，判 bug / 需求变更，禁止手改代码。
disable-model-invocation: true
sources:
  - reference/gstack/design-review/SKILL.md
  - reference/gstack/plan-design-review/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# feel-signoff

## 何时调用

QA 通过，用户说"验观感"、`/feel-signoff` 时。

## 输入

- `.aiassist/stories/<id>/ux/*.html`
- `.aiassist/stories/<id>/requirements.md`
- 已实现的产品/app
- `.aiassist/stories/<id>/qa-report.md`

## 输出

- `.aiassist/stories/<id>/feel-signoff.md`

## 执行步骤

1. **展示 HTML 参照** 和 **当前实现** 给用户。
2. **逐项检查**：颜色、排版、间距、动效、交互反馈、错误/降级状态表达。
3. **记录偏差**：对每个偏差，让用户分类：
   - **Bug**：实现偏离已签 REQ → 补标准增量 → test → implement。
   - **Req-change**：REQ 没写或写错 → 改 REQ → 重签 assertion-signoff → test → implement。
4. **生成 feel-signoff.md**。
5. **更新 workflow-state**：标记 feel-signoff 通过或退回。

## 检查清单

- [ ] 产品在目标环境启动无崩溃。
- [ ] 关键用户流程可走完。
- [ ] 视觉层面对照 HTML UX 参照：颜色、排版、间距、动效。
- [ ] 无系统错误弹窗 / 空白页。
- [ ] 降级/错误状态表达温和、不焦虑。

## 纪律

- **禁止在此阶段直接改代码**。
- 所有偏差必须回流到最高出错层（REQ 或 PRD）。
- 未通过 feel-signoff 禁止合并。

## 与参考项目的差异

- gstack `design-review` 是审计现有设计；我们把它收窄为"最终观感签核门"。
- soflow `design-ui` 生成 UI；我们把它当参照物。
- 核心差异：这里是"人对主观感受的最终裁决"，且裁决结果必须走 REQ 回流。

---
name: reflect
description: 沉淀本次 story 的经验：更新 engineering-lessons、ADR、STANDARDS，并定义下一个 crossing-line。
disable-model-invocation: true
sources:
  - reference/gstack/retro/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# reflect

## 何时调用

feel-signoff 通过，用户说"复盘"、"/reflect"时。

## 输入

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/assertion-signoff.md`
- `.aiassist/stories/<id>/feel-signoff.md`
- `.aiassist/stories/<id>/qa-report.md`

## 输出

- `.aiassist/global/engineering-lessons.md`
- `.aiassist/global/architecture.md`（ADR）
- `.aiassist/global/STANDARDS.md`
- `.aiassist/stories/<id>/workflow-state.yaml` 最终状态

## 执行步骤

1. **统计健康指标**：
   - feel-signoff 发现的 bug 数 / req-change 数
   - 每个阶段耗时/轮数
   - 哪些 REQ 验收标准在 feel-signoff 被发现遗漏
2. **提炼经验**：
   - 下次应该在哪个阶段多问什么问题
   - 哪些测试模式好用/不好用
   - 哪些架构决策需要记录为 ADR
3. **更新全局文档**：
   - `engineering-lessons.md`
   - `architecture.md`
   - `STANDARDS.md`
4. **定义下一个 crossing-line**：如果是多 phase 项目，明确 P2 进入二挡的条件。

## 健康指标

| 指标 | 本期值 | 目标 |
|---|---|---|
| feel-signoff bug 率 | N/M | 随时间下降 |
| feel-signoff req-change 率 | N/M | 随时间下降 |
| 实现者轮数 | N | ≤ 5 |
| 单 REQ 平均测试数 | N | ≥ 1 |

## 与参考项目的差异

- gstack `retro` 强调团队复盘；我们简化为个人/OPC 经验沉淀。
- soflow 强调两阶段加载知识；我们把它落地为全局 markdown 文档。
- superpowers 的 plan 结构给我们的 ADR 格式。

---
name: to-prd
description: 把需求访谈笔记和现有上下文合成为正式 PRD，不访谈，只合成。
sources:
  - reference/superpowers/skills/writing-plans/SKILL.md
  - reference/gstack/office-hours/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# to-prd

## 何时调用

用户说"生成 PRD"、"把讨论整理成 PRD"、"/to-prd"时。通常是在 `/demand-insight` 之后。

## 输入

- `.aiassist/stories/<id>/interview-notes.md`
- 可选：现有代码、相关文档、竞品参考

## 输出

`.aiassist/stories/<id>/prd.md`

## 执行步骤

1. **读取访谈笔记**：如果还没读，先读。
2. **探索仓库（如需要）**：了解当前代码状态，使用项目已有的领域词汇。
3. **判断是否需要前置调研**：若 PRD 中某些稳定块依赖外部技术事实（陌生 API、第三方协议、库能力边界），建议先调用 `/research` 产出带引用的笔记，再在 PRD 中引用它。
4. **勾勒测试 seams**：在写 PRD 时就考虑"在哪里测、测什么接口"。优先使用已有 seams，需要新 seams 时提到最高层。
5. **识别模块/服务边界**：明确每个稳定块会触碰哪些 module/service/executive，是否会引入新的跨模块耦合。提前解耦的决策写进 PRD 第 6.1 节。
6. **填充 PRD 模板**：使用 `templates/story/prd.md.template`。
7. **标注稳定/移动块**：明确哪些部分可以结晶为 REQ，哪些还在动。
8. **提交给用户审查**：请用户确认或修改。

## PRD 模板字段

```markdown
# <Story 名称>

## 1. 问题陈述
## 2. 解决方案
## 3. 用户故事
## 4. 稳定块
## 5. 移动块
## 6. 实现决策
## 7. 测试决策
## 8. 范围外
## 9. 其他说明
```

## 纪律

- **初衷锚定痛点**:"问题陈述"必须写用户痛点,不是具体方案。这是 story 的初衷锚点——方案会变,痛点不会。回流时靠它判断"初衷在不在"。例:✅"用户记不住每天情绪" / ❌"做一个情绪记录 App"。
- **不访谈**：只合成已有信息。如果信息不足，回退到 `/demand-insight`。
- **不写代码**：实现决策只到接口/模块层面，不写文件路径或代码片段。
- **提前想测试**：测试决策必须包含 seams 和测试类型（unit/集成/E2E/manual）。
- **提前解耦**：快速增长的项目，模块/服务边界在一挡就要明确。跨模块的 REQ 需要显式接口契约。
- **明确阶段切换线**：稳定块是下一阶段 `/crystallize` 的输入。

## 与参考来源的差异

- 我们不发布到问题跟踪系统。
- 我们增加 `稳定块` / `移动块` 字段，服务于 test-as-contract 的双挡模型。
- 我们明确指向 `.aiassist/stories/<id>/prd.md` 产物路径。

---
name: to-prd
description: 把需求访谈笔记和现有上下文合成为正式 PRD，不访谈，只合成。
disable-model-invocation: true
sources:
  - reference/mattpocock/skills/engineering/to-prd/SKILL.md
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
3. **勾勒测试 seams**：在写 PRD 时就考虑"在哪里测、测什么接口"。优先使用已有 seams，需要新 seams 时提到最高层。
4. **填充 PRD 模板**：使用 `templates/story/prd.md.template`。
5. **标注稳定/移动块**：明确哪些部分可以结晶为 REQ，哪些还在动。
6. **提交给用户审查**：请用户确认或修改。

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

- **不访谈**：只合成已有信息。如果信息不足，回退到 `/demand-insight`。
- **不写代码**：实现决策只到接口/模块层面，不写文件路径或代码片段。
- **提前想测试**：测试决策必须包含 seams 和测试类型（unit/E2E/manual）。
- **明确阶段切换线**：稳定块是下一阶段 `/crystallize` 的输入。

## 与 mattpocock to-prd 的差异

- 我们不发布到问题跟踪系统。
- 我们增加 `稳定块` / `移动块` 字段，服务于 test-as-contract 的双挡模型。
- 我们明确指向 `.aiassist/stories/<id>/prd.md` 产物路径。

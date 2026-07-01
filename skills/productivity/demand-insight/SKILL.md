---
name: demand-insight
description: 对抗式需求访谈。通过连续追问，逼出隐含需求、边界条件和自相矛盾，输出结构化的需求洞察笔记。
disable-model-invocation: true
sources:
  - reference/mattpocock/skills/productivity/grill-me/SKILL.md
  - reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md
  - reference/gstack/office-hours/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# demand-insight

## 何时调用

用户说"我要做一个新功能"、"我想重构这个"、"帮我看看这个需求"时。如果用户已经给了很完整的 PRD，直接调用 `/to-prd` 合成，不必访谈。

## 输入

- 用户的初步想法（一句话到一段描述）
- 可选：现有代码路径、相关工单、竞品参考

## 输出

`.aiassist/stories/<id>/interview-notes.md`

## 执行步骤

1. **确认范围**：用一句话复述用户要解决的问题，请用户确认或修正。
2. **多轮追问**：每次提 3-5 个具体问题，覆盖以下维度：
   - **谁**：谁感受这个痛点？他们今天怎么解决？
   - **为什么**：为什么他们会切换到这个方案？
   - **边界**：什么情况算成功？什么情况算失败？
   - **矛盾**：这个功能会不会和别的目标冲突？
   - **野心**：最窄的切入点是什么？
3. **记录洞察**：把用户的回答整理成结构化笔记，不要当场生成 PRD。
4. **收尾确认**：问用户"还有哪些我没问到的？"以及"现在可以生成 PRD 了吗？"

## 追问风格

- 不诱导、不替用户回答。
- 用户说"大概"、"可能"、"到时候再看"时，必须追问到可验证的精度。
- 把隐含假设显式化："你刚才默认了 X，是这样吗？"

## 纪律

- 本 skill **不写代码**、**不生成 PRD**、**不进入二挡**。
- 只产出访谈笔记，作为 `/to-prd` 的输入。
- 如果用户中途要求直接写代码，提醒："我们先完成需求洞察，再结晶 REQ，最后才能进二挡写测试和代码。"

## 输出格式

```markdown
# 访谈笔记 — <story-id>

## 核心问题
...

## 用户画像
...

## 关键边界
1. ...

## 隐含假设
1. ...

## 矛盾/风险
1. ...

## 最窄的切入点
...

## 待确认问题
- [ ] ...
```

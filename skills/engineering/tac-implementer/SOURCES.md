# 参考来源：implementer

## 借鉴的 reference 文件

- `reference/superpowers/skills/subagent-driven-development/SKILL.md`
- `reference/superpowers/skills/executing-plans/SKILL.md`
- `reference/superpowers/skills/writing-plans/SKILL.md`
- `reference/mattpocock/skills/engineering/implement/SKILL.md`

## 主要改动

- 测试只读；diff 碰测试 = 本轮作废。
- 每轮跑全套单元，停机条件为"全套绿"。
- 轮数上限逃生口。

## 未来局部更新建议

- superpowers subagent-driven-development / executing-plans 更新时，检查任务简报、审查包、模型选择策略。
- mattpocock implement 更新时，检查轻量实现模式。

## 改动记录

- 2026-07-03：明确提交时使用 `[tac-build]` 标签，一个 commit 只包含实现代码，不能包含测试文件。

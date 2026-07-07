# 参考来源：implementer

## 理念

内层实现循环的核心：实现代理对测试只读，逐轮迭代直至全套测试通过；人不直接修改实现代码，只修改需求和断言。把"红绿循环"自动化，但把契约所有权牢牢留在人手中。

## 借鉴的 reference 文件

- `reference/superpowers/skills/subagent-driven-development/SKILL.md`
- `reference/superpowers/skills/executing-plans/SKILL.md`
- `reference/superpowers/skills/verification-before-completion/SKILL.md`
- `reference/superpowers/skills/finishing-a-development-branch/SKILL.md`
- `reference/superpowers/skills/writing-plans/SKILL.md`
- `reference/mattpocock/skills/engineering/implement/SKILL.md`

## 主要改动

- 业务测试只读；diff 碰业务测试 = 本轮作废。
- 单元测试是 TDD 工具，由 `/implementer` 在实现过程中自行写改删，不进入契约。
- 用 `/tdd` 纪律做内层 RED → GREEN 循环。
- 每轮跑全套业务测试，停机条件为"全套业务测试绿"。
- 轮数上限逃生口。
- 自动连续模式：支持子代理连续执行和当前代理自循环，运行时可选择；断言一次性签核。

## 未来局部更新建议

- superpowers subagent-driven-development / executing-plans 更新时，检查任务简报、审查包、模型选择策略。
- mattpocock implement 更新时，检查轻量实现模式。

## 改动记录

- 2026-07-03：明确提交时使用 `[build]` 标签，一个 commit 只包含实现代码，不能包含测试文件。
- 2026-07-07：引入 `/tdd` 作为内层实现纪律；区分业务测试（契约）与单元测试（TDD 工具）。

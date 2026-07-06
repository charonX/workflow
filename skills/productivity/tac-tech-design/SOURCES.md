# 参考来源：tac-tech-design

## 理念

把用户语言翻译成系统语言。本 skill 通过单题对抗式提问，按依赖关系递进澄清模块边界、数据流、接口契约与测试 seams；目标是让 PRD 稳定块变成可结晶、可测试的技术方案，而不是直接给出代码。

## 借鉴的 reference 文件

- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/mattpocock/skills/engineering/codebase-design/SKILL.md`
- `reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md`
- `reference/mattpocock/skills/engineering/domain-modeling/SKILL.md`

## 主要改动

- 把 gstack 的工程审查问题清单收窄为"一挡内技术方案设计"。
- 吸收 mattpocock codebase-design 的 deep modules / seams / interface 词汇。
- 用对抗式访谈（grill-with-docs + domain-modeling）驱动方案澄清，而非直接根据 PRD 推导。
- 输出 `tech-design.md`，作为 `/tac-crystallize` 和 `/tac-test-author` 的输入。

## 未来局部更新建议

- gstack plan-eng-review 更新时，检查审查维度和复杂度检查清单。
- mattpocock codebase-design 更新时，检查模块/接口/seam 术语。
- mattpocock grill-with-docs / domain-modeling 更新时，检查对抗式提问方法。

## 改动记录

- 2026-07-03：创建 skill，定义对抗式技术方案设计流程与 `tech-design.md` 输出格式。
- 2026-07-03：增加 PRD 反向同步步骤，技术方案讨论中发现的需求调整需同步回 `prd.md`。

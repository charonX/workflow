# 参考来源：tech-design

## 理念

把用户语言翻译成系统语言。本 skill 通过单题对抗式提问，按依赖关系递进澄清模块边界、数据流、接口契约与测试 seams；目标是让 PRD 稳定块变成可结晶、可测试的技术方案，而不是直接给出代码。

**CLI 是默认测试 seam。** 产品 CLI 是人类和 agent 共用的真实接口，能把可观察行为变成稳定、快速、状态保持的测试；不能 CLI 化的部分才退到单元或浏览器 E2E。

**第一性原理。** 技术方案最容易被历史包袱绑架："上次用了 X""框架默认这样做""代码里已经有 Y"。本 skill 在关键决策点强制追问：哪些约束是真实的，哪些只是继承假设？从最小必要结构重新推导，再决定兼容历史代价是否值得。

## 借鉴的 reference 文件

- `reference/gstack/plan-eng-review/SKILL.md`
- `reference/mattpocock/skills/engineering/codebase-design/SKILL.md`
- `reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md`
- `reference/mattpocock/skills/engineering/domain-modeling/SKILL.md`

## 主要改动

- 把 gstack 的工程审查问题清单收窄为"一挡内技术方案设计"。
- 吸收 mattpocock codebase-design 的 deep modules / seams / interface 词汇。
- 用对抗式访谈（grill-with-docs + domain-modeling）驱动方案澄清，而非直接根据 PRD 推导。
- 输出 `tech-design.md`，作为 `/crystallize` 和 `/test-author` 的输入。

## 未来局部更新建议

- gstack plan-eng-review 更新时，检查审查维度和复杂度检查清单。
- mattpocock codebase-design 更新时，检查模块/接口/seam 术语。
- mattpocock grill-with-docs / domain-modeling 更新时，检查对抗式提问方法。

## 改动记录

- 2026-07-03：创建 skill，定义对抗式技术方案设计流程与 `tech-design.md` 输出格式。
- 2026-07-03：增加 PRD 反向同步步骤，技术方案讨论中发现的需求调整需同步回 `prd.md`。

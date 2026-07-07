# 参考来源：tdd

## 理念

TDD 是 AI 内层循环的代码纪律，不是工作流阶段。业务测试（由 `/test-author` 生成并签核）是契约；单元测试（由 `/implementer` 在 TDD 中自动写）是实现工具。两者分层，避免把实现细节测试误当作不可变更的契约。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/tdd/SKILL.md`
- `reference/mattpocock/skills/engineering/tdd/tests.md`
- `reference/mattpocock/skills/engineering/tdd/mocking.md`

## 主要改动

- 把 TDD 定位成 `/implementer` 的内部纪律，而不是独立工作流阶段。
- 明确区分单元测试（TDD 工具，AI 可改）与业务测试（契约，AI 只读）。
- 强调 RED 必须真实失败、GREEN 最小实现、一次一个 seam。
- 单元测试不进入签核契约，最终验收只看业务测试。

## 未来局部更新建议

- mattpocock tdd skill 更新时，同步 seams、反模式、循环规则。
- mattpocock mocking 指南更新时，同步 mock 边界建议。

## 改动记录

- 2026-07-07：创建 skill，定义 TDD 作为内层循环代码纪律，与业务测试契约分层。

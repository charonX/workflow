# 参考来源：tdd

## 理念

TDD 是 AI 内层循环的代码纪律，不是工作流阶段。业务测试（由 `/test-author` 生成并签核）是契约；单元测试（由 `/implementer` 在 TDD 中自动写）是实现工具。两者分层，避免把实现细节测试误当作不可变更的契约。

## 借鉴的 reference 文件

- `reference/mattpocock/skills/engineering/tdd/SKILL.md`
- `reference/mattpocock/skills/engineering/tdd/tests.md`
- `reference/mattpocock/skills/engineering/tdd/mocking.md`
- `reference/mattpocock/skills/engineering/code-review/SKILL.md`（v1.1.0）：mattpocock 在该版本将 `tdd` 中的 refactor 阶段移出。
- `reference/agent-skills/skills/test-driven-development/SKILL.md`：测试金字塔、测试尺寸（Small/Medium/Large）、DAMP over DRY、Prove-It Pattern、测试替身优先级、Arrange-Act-Assert。
- `reference/superpowers/skills/test-driven-development/SKILL.md`：common rationalizations 表、Red Flags 清单、TDD 循环图。
- `reference/superpowers/skills/test-driven-development/writing-good-tests.md`（2026-07 新增）：Name the Break、Exercise the Real Thing 两条原则、mock 纪律、变异检查。

## 主要改动

- 把 TDD 定位成 `/implementer` 的内部纪律，而不是独立工作流阶段。
- 明确区分单元测试（TDD 工具，AI 可改）与业务测试（契约，AI 只读）。
- 强调 RED 必须真实失败、GREEN 最小实现、一次一个 seam。
- 单元测试不进入签核契约，最终验收只看业务测试。
- 引入 agent-skills 的测试金字塔、测试尺寸、DAMP over DRY、Prove-It Pattern、测试替身优先级。
- **v0.10.0 起**：遵循 mattpocock v1.1.0 的 reshape，将 refactor 移出 `/tdd`。`/tdd` 只做 RED → GREEN；深度重构由 `/implementer` 的 refactor subagent 在 slice 完成后处理。

## 未来局部更新建议

- mattpocock tdd skill 更新时，同步 seams、反模式、循环规则。
- mattpocock code-review skill 更新时，同步重构/代码异味相关建议，但保持 refactor subagent 在内层循环中的位置。
- mattpocock mocking 指南更新时，同步 mock 边界建议。
- agent-skills `test-driven-development` 更新时，同步测试金字塔、测试尺寸、DAMP、Prove-It、测试替身优先级。

## 改动记录

- 2026-07-07：创建 skill，定义 TDD 作为内层循环代码纪律，与业务测试契约分层。
- 2026-07-09：引入 agent-skills `test-driven-development` 的测试金字塔、测试尺寸、DAMP over DRY、Prove-It Pattern、测试替身优先级、Arrange-Act-Assert。
- 2026-07-09：将 refactor 移出 `/tdd`，改为由 `/implementer` 的 refactor subagent 处理。
- 2026-08-02：吸收 superpowers TDD skill 的 `writing-good-tests.md`（v6.2.0）：新增 Name the Break 门函数、Mock 纪律（Exercise the Real Thing、正确层级、完整结构、mock 膨胀→集成测试）、Change Detector 反模式、变异检查。
- 2026-08-06：PRD 与 tech-design 合并（`design/adr/0004`）：seam 定义与对齐契约引用从 `tech-design.md` 改到 `prd.md` §10-11。

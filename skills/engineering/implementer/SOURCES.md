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
- `reference/mattpocock/skills/engineering/code-review/SKILL.md`（v1.1.0）：mattpocock 将 refactor 从 `tdd` 移出到 `code-review`；我们采用 refactor subagent 方案，保持 `/review` 手动可选。
- `reference/agent-skills/skills/incremental-implementation/SKILL.md`：Simplicity First、Scope Discipline、One Thing at a Time、Keep It Compilable、Feature Flags、Safe Defaults、Rollback-Friendly。

## 主要改动

- 业务测试只读；diff 碰业务测试 = 本轮作废。
- 单元测试是 TDD 工具，由 `/implementer` 在实现过程中自行写改删，不进入契约。
- 用 `/tdd` 纪律做内层 RED → GREEN 循环。
- 每个 slice 业务测试全绿后，派发独立的 **refactor subagent** 做一轮安全重构，减少 AI 自我确认偏见。
- 每轮跑全套业务测试，停机条件为"全套业务测试绿"。
- 轮数上限逃生口。
- 自动连续模式：支持子代理连续执行和当前代理自循环，运行时可选择；断言一次性签核。
- 引入 agent-skills `incremental-implementation` 的 Rule 0–5 作为子代理任务简报中的增量实现纪律。
- **v0.15.0 起**：fix subagent 支持 `/bug` 调用，接受 bug 上下文（会话内传入）和回归测试作为上下文，提交 `[bugfix] BUG-NNN` commit。

## 未来局部更新建议

- superpowers subagent-driven-development / executing-plans 更新时，检查任务简报、审查包、模型选择策略。
- mattpocock implement 更新时，检查轻量实现模式。
- mattpocock code-review 更新时，同步重构/代码异味建议，但保持 refactor subagent 在内层循环中的位置。
- agent-skills `incremental-implementation` 更新时，检查 Rule 0–5、切片策略、feature flags、rollback-friendly 实践。

## 改动记录

- 2026-07-03：明确提交时使用 `[build]` 标签，一个 commit 只包含实现代码，不能包含测试文件。
- 2026-07-07：引入 `/tdd` 作为内层实现纪律；区分业务测试（契约）与单元测试（TDD 工具）。
- 2026-07-09：引入 agent-skills `incremental-implementation` 的 Simplicity First、Scope Discipline、One Thing at a Time、Keep It Compilable、Feature Flags、Safe Defaults、Rollback-Friendly 纪律。
- 2026-07-09：将 refactor 从 `/tdd` 移出，改为 `/implementer` 在每个 slice 后派发 refactor subagent 处理。
- 2026-07-10：fix subagent 支持 `/bug` 单 bug 修复模式（由 `/bug` 调用，不再读 bug 工件）。

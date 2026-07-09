# ADR 0001: 将 refactor 从 `/tdd` 移出到 `/implementer` 的 refactor subagent

## Status

Accepted

## Context

mattpocock/skills 在 v1.1.0 中将 `tdd` skill 的 refactor 阶段移出，放到 `code-review` 中。其理由是：写代码的同一个 agent 很难客观发现自己代码的坏味道。

在我们的双循环工作流中，`/tdd` 是 `/implementer` 内部的代码纪律，负责用单元测试驱动实现。当前 `/tdd` 的规则是 RED → GREEN → 当前 slice 业务测试全绿后做"必要重构"。这意味着实现 agent 既要写代码，又要审查自己代码的质量。

我们认同"同上下文偏见"问题：AI 在自己刚写的代码上下文中，倾向于维护原有结构、忽略命名和抽象问题。但直接把 refactor 移到用户触发的 `/review --stage=code` 会带来两个问题：

1. `/review` 在我们的设计中是**手动可选检查点**，不是内层循环的必经环节。如果 `/implementer` 自动调用它，会污染其语义。
2. 代码审查是**开放性活动**，没有客观终止条件。自动 review → 自动修改 → 自动 review 容易进入无限循环，且没有清晰的"够好了"标准。

## Decision

1. `/tdd` 的职责收缩为纯 **RED → GREEN**。
   - 只允许 GREEN 后的最小清理（ obvious 坏命名、格式）。
   - 不再承担"深度重构"职责。

2. `/implementer` 在每个 slice 业务测试全绿后，派發一个**独立的 refactor subagent**。
   - 子代理拥有相对新鲜的上下文，减少自我确认偏见。
   - 只做**一轮**，输出报告后停止。
   - 严格限定在**当前 slice 已修改的文件**内。
   - 只允许**安全重构**：重命名、提取重复 helper、简化过长函数、消除当前 diff 内明显异味。
   - 禁止：改变接口契约、改变行为、引入新抽象、修改业务测试。
   - 重构前后必须跑全套业务测试 + 相关单元测试，全绿方可提交。
   - 如果测试变红，回滚重构并报告。

3. `/review --stage=code` 保持**用户手动触发**。
   - 负责更深度的设计审查、安全/性能/测试覆盖风险。
   - 不被 `/implementer` 自动调用，避免无限循环和成本失控。

## Consequences

### 正面

- 减少 AI 自我确认偏见：重构由一个相对独立的子代理审视。
- 内层循环仍保持自治：`/implementer` 不需要等人触发 `/review` 就能完成一个 slice。
- 重构时机仍接近写代码时刻：在每个 slice 完成后立即进行，上下文尚在。
- `/review` 的 manual/optional 语义保持清晰。

### 负面

- 每个 slice 多一次 subagent 调用，小任务成本上升。
- 需要严格的范围锁和终止条件，否则容易过度重构。
- 父代理验证步骤增加：子代理 refactor 后父代理必须再次验证测试和 diff。
- 用户需要理解两个审查层级的区别：
  - **refactor subagent**：内层循环的一轮安全清理，自动、一轮、范围锁。
  - **`/review --stage=code`**：用户发起的深度多维度审查，可选、 specialist panel、无自动修改。

## Alternatives Considered

### Alternative A: 把 refactor 移到 `/review --stage=code`，由 `/implementer` 自动调用

- **Rejected**：`/review` 是手动可选检查点，自动调用会把它变成必经门；且代码审查开放性强，自动循环难以终止。

### Alternative B: 在 `/tdd` 内部用子代理做重构

- **Rejected**：虽然能解决同上下文偏见，但没有真正"移出" `/tdd`，`/tdd` 的职责仍不清晰，且重构时机仍被 `/tdd` 生命周期约束。

### Alternative C: 完全不做自动重构，只保留手动 `/review`

- **Rejected**：会导致大量"能绿但不干净"的代码累积到 review 阶段，增加人的审查负担，也违背了"内层循环自治"的初心。

## Related

- `skills/engineering/tdd/SKILL.md`
- `skills/engineering/implementer/SKILL.md`
- `skills/productivity/review/SKILL.md`
- `reference/mattpocock/skills/engineering/tdd/SKILL.md` (v1.1.0)
- `reference/mattpocock/skills/engineering/code-review/SKILL.md` (v1.1.0)

# ADR 0003: 让 BUILD 以 PRD 意图为导向，而非仅测试通过

## Status

Accepted（2026-07-16）

## Context

v0.15 之前，BUILD 阶段的核心成功标准是"业务测试全绿"。实践中反复出现一种偏差：实现代码能让已签核的测试通过，但 PRD 中定义的失败态、表单校验规则、用户操作分支、副作用/回滚等行为并未真正落地。典型症状包括：

- 错误处理只覆盖测试里写死的一种异常，其他失败路径返回 500 或默认成功页。
- 表单校验只做了"非空"，没做 PRD 里要求的格式、长度、跨字段规则。
- 操作流程只实现了 happy path，分支页面/状态切换缺失。
- 为通过测试写特判、mock 掉真实依赖、或阉割功能。

根因有两层：

1. **PRD 本身不够细致。** 早期 PRD 模板只要求"稳定块"和"移动块"，对操作流、验证规则、错误状态没有结构化强制，导致这些意图在结晶成 REQ 前就已经模糊。
2. **BUILD 的验收口径只有测试。** `/implementer` 虽然口头上说"测试全绿只是最低门槛"，但没有显式步骤要求子代理把 PRD 意图映射到代码，也没有独立角色去对抗式检查 PRD 是否被实现。

本 ADR 通过**上游强制补全 PRD → 中游拦截缺口 → 下游可追溯 + 对抗对齐**，把"实现什么"的裁判权提前锁定在 PRD/REQ 层。

## Decision

1. **PRD 模板强制产出四组结构化章节**：用户操作流、表单与输入验证、错误状态与失败响应、复杂度分级。详见 `templates/story/prd.md.template` 第 6-9 节与第 14 节自检查表。

2. **引入 `simple / complex` 复杂度分级**：
   - `complex`：涉及模块数 ≥3、有用户输入、操作分支 ≥2、有外部依赖 / I/O 等，必须完整填写第 6-8 节。
   - `simple`：可减少表格粒度，但第 8 节"错误状态"不可跳过。

3. **`/to-prd` 必须做 PRD 完整性自检查**。生成 `prd.md` 后逐项确认操作流、验证规则、错误状态、复杂度分级；未通过项必须归入"移动块"或在"补充说明"中给出 N/A 理由。

4. **`/crystallize` 在生成 REQ 前审查 PRD 完整性**。对照 `prd.md` 第 14 节自检查表及 crystallize 版清单重新验证。未通过时：
   - 生成 `.aiassist/stories/<id>/prd-gap-report.md`，列出具体缺失项和建议动作。
   - **不生成 `requirements.md`**。
   - 停止并提示用户回流 `/to-prd` 补全缺口。

5. **`/signoff --stage=assertion` 增加 PRD 完整性门**：
   - 存在未关闭的 `prd-gap-report.md` 时签核必须失败。
   - 签核清单增加 PRD 第 6-8 节已覆盖或声明 N/A 的确认。

6. **`/implementer` 增加 PRD→代码 可追溯性声明**：每个 implementer subagent 完成 slice 后，必须在 `build-progress.md` 中写入一张表，逐条列出本 slice 涉及的 PRD 意图（操作流步骤、验证规则、错误状态、UX 结构/行为等），并给出对应的实现文件、测试文件和覆盖状态（`COVERED` / `PARTIAL` / `GAP`）。

7. **`/implementer` 增加 PRD 对齐子代理**：父代理在业务测试全绿且 diff 验证通过后，必须派发独立的 PRD 对齐子代理，对抗式检查 PRD 第 6-8 节是否已在实现中完整表达。检查发现缺口时：
   - 不派发 refactor subagent，不标记 slice 完成，不进入下一个 slice。
   - 按 `/bug` 分类初步定为 `missing-implementation` / `missing-test` / `prd-error` / `tech-design-gap`。
   - 向用户报告 blocker，决定继续补实现、补测试，或回流 `/to-prd` / `/tech-design`。

8. **保持"测试只读"和"人签断言"约束不变**。本决策不放宽业务测试不可修改、不转移断言签核责任；只是让测试全绿从"完成"降为"必要门槛"。

## Consequences

### 正面

- **PRD 意图在结晶前被强制显式化。** 操作流、验证、错误状态不再靠实现时"脑补"，而是在一挡就写清楚。
- **缺口在进入 TEST/BUILD 前被拦截。** `/crystallize` 和 `/signoff` 两道门确保不完整的 PRD 不会流入实现。
- **BUILD 的验收口径从"测试绿"升级为"测试绿 + PRD 对齐"。** 可追溯性表 + 对抗式对齐子代理使"实现是否完整"可被独立审查。
- **减少"为绿而绿"的投机实现。** 子代理必须说明每条 PRD 意图对应哪段代码、哪个测试，伪造覆盖的成本显著提高。
- **为 REFLECT 提供结构化输入。** `build-progress.md` 中的可追溯性表成为人工最终验收的客观依据。

### 负面

- **上游 PRD 工作量增加。** 小 story 也要填错误状态，complex story 必须写完整操作流和验证。缓解：simple 可简写，允许 N/A + 理由。
- **`/crystallize` 可能过度拦截。** 如果自检查表过严，会导致频繁回流。缓解：GAP 必须具体 actionable；N/A 理由被接受。
- **PRD 对齐子代理增加 BUILD 成本。** 每个 slice 多一次子代理调用。缓解：simple story 可适度简化对齐深度；complex story 严格执行。
- **子代理可能伪造可追溯性表。** 缓解：父代理对照 diff/test 审查 + PRD 对齐子代理交叉验证；`ALIGNED` 是 slice 完成必要条件。
- **PRD 与实现之间的映射仍依赖模型判断。** 无法 100% 自动化，但显式表格和对抗检查比隐式依赖更可靠。

## Alternatives Considered

### Alternative A: 仅通过升级 LLM 模型解决

- **Rejected**：模型能力提升能缓解实现遗漏，但无法替代结构性约束。只要 BUILD 的验收口径只有测试，模型就会优先优化测试通过率。需要把"PRD 对齐"变成显式步骤。

### Alternative B: 仅增加测试数量

- **Rejected**：测试无法覆盖缺失的 PRD 意图。如果 PRD 没写失败态，测试作者也写不出对应断言。问题根源在需求层，不在测试层。

### Alternative C: 在 `/implementer` 中加一段 prompt，不新增子代理

- **Rejected**：同一会话的子代理容易受自身实现偏见影响，难以客观审查自己刚写的代码。独立的 PRD 对齐子代理提供对抗视角，且可追溯性表需要被父代理和子代理双重审查。

### Alternative D: 把 PRD 对齐放到 `/qa-runner`

- **Rejected**：QA 阶段再发现 PRD 意图缺失会导致大量返工。对齐检查应在 slice 完成时就做，把小缺口留在 BUILD 内解决。

### Alternative E: 让 `/reflect` 人工验收所有 PRD 意图

- **Rejected**：把结构性检查全部推到最终人工门，既增加人负担，也让 BUILD 阶段失去自我纠正能力。REFLECT 应只处理无法自动化的纯审美/体验判断。

## Related

- `templates/story/prd.md.template`
- `templates/story/signoff.md.template`
- `skills/productivity/to-prd/SKILL.md`
- `skills/productivity/signoff/SKILL.md`
- `skills/engineering/crystallize/SKILL.md`
- `skills/engineering/implementer/SKILL.md`
- `skills/productivity/bug/SKILL.md`
- `design/test-as-contract-workflow.md`
- `CLAUDE.md` 中"我们的循环工作流"与"回流机制"章节

## 改动记录

- 2026-07-16：新增 ADR；上游 PRD 模板与 `/to-prd` 强制完整性；`/crystallize` 拦截缺口生成 `prd-gap-report.md`；`/signoff` 增加 PRD 完整性门；`/implementer` 增加 PRD→代码 可追溯性声明与 PRD 对齐子代理。

# ADR 0009: 双真值模型——story 完成后 spec 完成即删，代码为逻辑真值

## Status

Accepted（2026-08-17）。**Revised（2026-08-20）**：落地方式从"原地归档"改为"完成即删"——已完成 story 的 spec 不再保留在工作区，随删除提交进 git 历史。

## Context

社区趋势"代码为逻辑真实来源"命中真实痛点：story 完成后 spec 文档会漂移（后续改代码不回改旧 spec），且历史 spec 堆积吃 AI 上下文。当前流程在 REFLECT 后把 story 级 spec 原样留在目录、`completed` 标记**只写不读**——后续 AI 自由探索时可能把漂移的旧 spec 当权威，grep 历史时优先命中旧 prd/requirements，导致"以文档为准"而非"以代码为准"。

但"归档后只参考代码"不能踩掉四道承重墙里的**初衷锚点**。正解是分清两种真值，且让意图真值的唯一归宿是全局文档。

## Decision

1. **双真值模型**：
   - **逻辑真值**（系统当前如何行为、在哪实现）→ **代码 + 测试**（story 完成后）。
   - **意图真值**（为什么存在、验收基准、设计决策）→ **全局文档**（`adr/`、`business-capabilities.md`、`CONTEXT.md`、`STANDARDS.md`、`engineering-lessons.md`）+ 构建期内 story spec。
   - "真理只向下流"是**构建期**公理（story 内 PRD→REQ→测试→代码，spec 权威）；story 完成后逻辑真值归代码、意图真值归全局文档。

2. **REFLECT 完成即删**：`/reflect` 收尾时按"读 story 产物 → 提炼上提 → 上提完整性核对 → 写 `status: completed` → 用户确认删除"的顺序，将整个 story 目录 `git rm` 提交。删除提交即归档：完整证据留在 git 历史，`git show` 可回溯；工作区不再保留任何已完成 story 的 spec（含 ux/、design_handoff/、workflow-state.yaml）。

3. **上提完整性核对**（替代"归档 spec 兜底"）：删除前确认架构/技术决策 → `adr/`、能力/实体/REQ→测试 → `business-capabilities.md`、术语 → `CONTEXT.md`、工程经验 → `engineering-lessons.md`/`STANDARDS.md`/`checklists/` 均已上提，有遗漏先补全再删。

4. **引用语义**：新 story / 修 bug 逻辑看代码、意图看全局文档。已完成 story **不回流**（回流=归档重做/删 story 只发生在进行中），因此"查已完成 story 归档 spec（含初衷）"指向不存在的场景，不再需要；后续问题走 `/bug`（看代码）或新 story。

5. **mtime 启发式加固**：bug/review/research 选"当前 story"时跳过 `status: completed` 的 story。新流程下 completed 目录会消失，逻辑自然成立；保留以兼容存量。

## 与承重墙的关系

- **初衷锚点保留**：意图真值上提为全局文档（ADR / 能力地图 / CONTEXT / engineering-lessons），初衷锚点始终在 workflow-state 的 `intention` + 当前 PRD 问题陈述 + 全局文档中，不依赖已完成 story 的 spec。四道承重墙不变。
- **构建期纪律不变**：测试前置、实现者对测试只读、PRD 对齐子代理、REQ 唯一出生地——全部保留。变化的只是"story 完成后 spec 的去留"。

## Consequences

### 正面

- **对齐社区趋势**：代码为逻辑真值，解决"读漂移 spec 得出错误结论"。
- **上下文收敛**：后续 AI 不读历史 spec，只读代码 + 全局文档，OPC 单人场景上下文更省。
- **消除 spec 污染源**：已完成 story 的 prd/requirements/signoff 不再停留在工作区，AI grep 历史时不会被旧 spec 误导为当前事实——"以代码为事实依据"从原则变成机制。
- **completed 成为真实信号**：mtime 启发式不再把刚完成的 story 重选为"当前"。

### 代价

- **依赖 REFLECT 上提完整**：若某已完成 story 的意图没上提为全局文档，将无法在 `global/` 查到（需 `git show` 回溯删除提交）。这是有意的取舍——用"REFLECT 强制上提 + git 历史兜底"替代"工作区旧 spec 兜底"。
- **REQ-TRACE 成为历史标签**：测试头 `// REQ-TRACE: <story-id>/<req-id>` 指向已删除的 requirements.md；REQ→测试映射由 `business-capabilities.md` 继续承载。
- **术语微调**："代码永远不是真理来源"需限定为构建期。

## 替代方案

- **物理移入 `stories/completed/<id>/`**：目录级隔离，但破坏 post-REFLECT 工具与 git 路径追踪，mtime 启发式仍需跳。否决。
- **复用 `archive/` 移入**：与"回流重做"语义混淆。否决。
- **原地归档（本 ADR 原方案）**：文件全留只打 completed 标记，spec 仍污染 AI grep，被修订取代。
- **只参考代码、不留意图**：误解——本 ADR 不是"不留意图"，而是"意图真值只存全局文档、不留 story 级 spec"；全局文档 + 构建期 spec + git 历史共同兜底意图。

## 相关文件

- `skills/productivity/reflect/SKILL.md`（完成即删）
- `skills/productivity/story/SKILL.md`（引用规则）
- `skills/productivity/{bug,review,research}/SKILL.md`（mtime 启发式跳过，存量兼容）
- `templates/story/{workflow-state,prd}.md.template`
- `CLAUDE.md` / `README.md` / `templates/claude/project-claude-appendix.md.template`（公理澄清）
- `design/adr/0006-guardrails-and-graded-defense.md`（初衷锚点承重墙）

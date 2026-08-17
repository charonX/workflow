# ADR 0009: 双真值模型——story 完成后 spec 原地归档，代码为逻辑真值

## Status

Accepted（2026-08-17）。

## Context

社区趋势"代码为逻辑真实来源"命中真实痛点：story 完成后 spec 文档会漂移（后续改代码不回改旧 spec），且历史 spec 堆积吃 AI 上下文。当前流程在 REFLECT 后把 story 级 spec 原样留在目录、`completed` 标记**只写不读**——后续 AI 自由探索时可能把漂移的旧 spec 当权威。

但"归档后只参考代码"会踩掉四道承重墙里的**初衷锚点**（回流判断 / bug vs 需求变更 / 验收基准全靠意图文档）。正解是分清两种真值。

## Decision

1. **双真值模型**：
   - **逻辑真值**（系统当前如何行为、在哪实现）→ **代码**（story 完成后）。
   - **意图真值**（为什么存在、验收基准、设计决策）→ **全局文档**（`adr/`、`business-capabilities.md`、`CONTEXT.md`、`STANDARDS.md`）+ 构建期内 story spec。
   - "真理只向下流"是**构建期**公理（story 内 PRD→REQ→测试→代码，spec 权威）；story 完成后逻辑真值归代码、意图真值归全局文档。

2. **REFLECT 原地归档**：不移动文件。workflow-state 标 `status: completed` + `completed: true` + `completed_at`；prd.md 状态行加"已完结（历史记录）"。已完成 story 的 spec 降级为历史记录。

3. **引用语义**：新 story / 修 bug 逻辑看代码、意图看全局文档；不把已完成 story 的 spec 当权威。回流判断（bug vs 需求变更、初衷漂移）可查已完成 story 的归档 spec（含初衷）。

4. **mtime 启发式加固**：bug/review/research 选"当前 story"时跳过 `status: completed` 的 story——`completed` 从只写变为第一个真实消费者。

## 与承重墙的关系

- **初衷锚点保留**：意图真值上提为全局文档（ADR / 能力地图 / CONTEXT），回流判断仍可查归档 spec（含初衷）。四道承重墙不变。
- **构建期纪律不变**：测试前置、实现者对测试只读、PRD 对齐子代理、REQ 唯一出生地——全部保留。变化的只是"story 完成后 spec 的权威地位"。

## Consequences

### 正面

- **对齐社区趋势**：代码为逻辑真值，解决"读漂移 spec 得出错误结论"。
- **上下文收敛**：后续 AI 不读历史 spec，只读代码 + 全局文档，OPC 单人场景上下文更省。
- **completed 成为真实信号**：mtime 启发式不再把刚完成的 story 重选为"当前"。

### 代价

- **意图只在全局文档层**：若某已完成 story 的细节意图没被上提为 ADR / 能力地图，后续只能靠归档 spec（回流时查）——要求 REFLECT 上提足够完整。
- **术语微调**："代码永远不是真理来源"需限定为构建期，3 处绝对表述 + 4 处无限定"真理只向下流"已澄清。

## 替代方案

- **物理移入 `stories/completed/<id>/`**：目录级隔离，但破坏 post-REFLECT 工具（design-handoff 读 ux/）与 git 路径追踪，mtime 启发式仍需跳。否决。
- **复用 `archive/` 移入**：与"回流重做"语义混淆。否决。
- **只参考代码、不留意图**：踩掉初衷锚点承重墙，回流 / bug vs 需求变更 / 验收全失效。否决。

## 相关文件

- `skills/productivity/reflect/SKILL.md`（原地归档）
- `skills/productivity/story/SKILL.md`（引用规则）
- `skills/productivity/{bug,review,research}/SKILL.md`（mtime 启发式跳过）
- `templates/story/{workflow-state,prd}.md.template`
- `CLAUDE.md` / `README.md` / `templates/claude/project-claude-appendix.md.template`（公理澄清）
- `design/adr/0006-guardrails-and-graded-defense.md`（初衷锚点承重墙）

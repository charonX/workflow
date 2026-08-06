# ADR 0005: 快速收敛——从"前载完整"到"快速迭代"

## Status

Accepted（2026-08-06）

部分取代 ADR 0003 的决策 #4（crystallize 拦截缺口生成 `prd-gap-report.md`）与 #5（signoff 的 PRD 完整性门）。

## Context

用户实际使用后提出核心观察：**PRD 不可能一次设计全面**（前期能力/精力有限），验收时一定会出现要修改的地方。ADR 0003 建立在"PRD 足够完整 → 实现一次对齐"的假设上，因此前载了大量完整性机制：crystallize 的 PRD 完整性硬拦截（`prd-gap-report.md` 阻断）、signoff 的全量断言签核。实践中这变成：

1. **缺口被文档化阻断，而不是在对话中解决**。crystallize 生成 `prd-gap-report.md` 并停止结晶，逼用户回流 `/to-prd`——但缺口本应在 to-prd 的对话阶段、或 review 阶段就识别补掉。
2. **signoff 全量签核过重**。人逐项确认每个 REQ 有测试、TRACE 完整、无占位符——这些是 AI 能可靠自检的项，不是人的高杠杆判断。
3. **前载完整与"验收一定会改"的现实冲突**。把时间花在把 PRD 磨到"完整"，不如快速进入实现，让 QA 验收 + 就地补全来收敛。

本 ADR 把工作流哲学从"**前载完整（get it right upfront）**"转向"**快速收敛（iterate to convergence）**"。

## Decision

1. **PRD 标准从"完整"降为"可启动"**。稳定块 + 主流程 + 复杂度分级即可进入结晶；操作流分支、验证规则、错误状态等可后补（见第 3 条）。ADR 0003 的 PRD 模板强制四组章节（§6-9）保留，但解读为"启动即可、缺口后补"，不再是启动门槛。

2. **缺口强制归类，不许悬空**。任何识别出的缺口要么**就地补**，要么显式归类：**移动块（§5，暂不做）** / **新建 story（转去新 story 实现）** / **范围外（§12，明确不再实现）**。没有"待迭代"这种模糊悬空状态。

3. **补缺口场所前移**。to-prd 对话阶段（自检查）与 `/review --stage=prd` 是补缺口的两个主要场所；crystallize 只做**对话式轻确认**——可从上下文推导的就地补，需判断的问用户归类（四分法），然后继续结晶，**不生成 `prd-gap-report.md`、不阻断**。

4. **signoff 只签高风险项**。人逐项确认：初衷锚定、跨模块接口契约（§10.4）、expected 值来源、安全边界、每个 GAP 的去处。其余（REQ 覆盖、TRACE 完整、无占位符、无 snapshot、边界覆盖）由 AI 自检并写入 `signoff.md` 供人抽查。

5. **QA 验收缺口走 `/bug` req-gap 就地补全——默认收敛路径**。这不是异常，是预期收敛机制：验收发现意图缺口 → 就地补 PRD/REQ/测试 → 继续，直到全绿。缺口超出当前 story 范围 → 显式归类（新建 story / 范围外）。

## 与 ADR 0003 的关系

- **被取代**：0003 决策 #4（crystallize 完整性拦截 + `prd-gap-report.md`）、#5（signoff 检查 gap report）。
- **保留（承重墙）**：
  - 0003 决策 #6-7：`/implementer` 的 PRD→代码可追溯性声明 + PRD 对齐子代理——这是"为绿而绿"（测试全绿但 PRD 意图未落地）的**真正防线**，位于 BUILD 阶段，与结晶门无关。
  - 0003 决策 #8：测试只读、人签断言。
  - 测试前置（REQ → 测试 → 实现的契约链）、双挡跨越线、REQ 唯一出生地。

## Consequences

### 正面

- **缺口在对话/review 中解决**，crystallize 不再把"该对话里补的事"变成文档化阻断。
- **人确认点大幅减少**：signoff 只签高风险，AI 自检全量供抽查。
- **快速迭代成为默认**：快速出方案 → 快速实现 → QA 验收缺口就地补全收敛，符合单人 OPC 的实际使用模式。

### 代价

- **PRD 意图可能后置**：部分验证规则/错误状态在 QA 才补，BUILD 时实现者依赖的契约信息更少。由 implementer 的 PRD 对齐子代理兜底（它会在 BUILD 中发现并报告缺口）。
- **依赖 QA 验收的完整性**：若 QA 覆盖不严，后补的缺口可能漏网。由 `/qa-runner` 的回归 + REFLECT 门 2 兜底。

## 替代方案

- **完全移除完整性门但缺口悬空**：缺口无去处，靠 QA 碰运气，否决。
- **保留 gap report 但改软**：仍是多余的文档化中间层，且 signoff 仍需消费它，否决。

## 相关文件

- `skills/engineering/crystallize/SKILL.md`（对话式轻确认）
- `skills/productivity/to-prd/SKILL.md`（自检查 + 缺口四分法）
- `skills/productivity/signoff/SKILL.md`（只签高风险）
- `skills/productivity/bug/SKILL.md`（req-gap 默认收敛路径）
- `templates/story/prd.md.template`（§14 GAP 归类）
- 前身：`design/adr/0003-prd-intent-driven-build.md`

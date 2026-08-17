# ADR 0007: 断言自动签核 + 按需升级（门 1 演进）

## Status

Accepted（2026-08-17）。

## Context

ADR 0005 落地"快速收敛"后，signoff 已从全量签核收敛为只签高风险项。用户又经数轮实际使用，得到新的经验观察：**只要 PRD 和 design 做得够好，REQ 与 test 的生成就是机械翻译，不需要人参与确认。** 这让门 1 剩余的"人逐项签高风险"也显得是重复劳动——人的判断功夫已经花在 PRD/design 的 expected 值锚点上，REQ/test 只是把锚点翻译成可执行断言。

本 ADR 把门 1 从"人签高风险"进一步演进为"**AI 全量自检 + 按需升级**"，并落地 ADR 0006 留账的"防线分级"方向：按**推导置信度**（能否机械 trace 到规格锚点）触发人确认，而非按 simple/complex 一刀切。

## Decision

1. **expected 值锚点上移到规格层**。PRD 必须为每个稳定块提供具体的预期值锚点（§6.3 例子表、§7 有效/无效例子、§10.4 golden 样例）。"什么算对"仍由人定义——但定义的位置从"签断言"上移到"定锚点"。

2. **test-author 从锚点机械推导 expected**，测试头部标注 `// EXPECTED-TRACE`（如 `prd.md §6.3 row N`）。推导不出 = PRD 缺口：可从上下文推导的就地补 PRD，需人判断的登记为升级点。**禁止**从当前代码输出抄 expected。

3. **门 1 → 按需升级门**。signoff 默认执行 AI 全量自检（含每条 `EXPECTED-TRACE` 的交叉验证：锚点真实存在于 prd.md 且值一致），写 `signoff.md`、提交 `[test] assertion-signoff`、置 `phase: BUILD`。仅在升级点停下问人：初衷漂移信号、跨模块契约歧义、expected 推导不出且无法就地补、安全边界、范围决策（新 story/范围外）。无升级 → 零打断。

4. **REQ/test/signoff 合并为自动链**。`/story` 路由到 CRYSTALLIZE 时一次会话跑完 crystallize → test-author → signoff，phase 由各 skill 显式推进，升级点停下。单 skill 仍可独立调用。

5. **四道承重墙不变**。测试前置、实现者对测试只读、PRD 对齐子代理、初衷锚点——全部保留。反作弊线从"人签 expected"改为"expected 可 trace + signoff 交叉验证"，残余错误由 PRD 对齐子代理与 QA/REFLECT 兜底。

## 与 ADR 0005 / 0006 的关系

- **被取代**：0005 #4（signoff 只签高风险，人逐项确认）→ 演进为 AI 全量自检 + 按需升级。初衷锚定、契约准确、expected 来源、安全边界、GAP 去处仍是被检查的项，但默认由 AI 检查，仅异常时升级。
- **落地**：0006 留账的"防线分级"（按人投入注意力分级）→ 落地为"按推导置信度触发升级"。
- **保留**：0005 的缺口强制归类、QA 就地补全收敛路径；0006 的四道承重墙。

## Consequences

### 正面

- **人确认点大幅减少**：PRD/design 好的 story 从 CRYSTALLIZE 到 BUILD 零打断。
- **反作弊线更结构**：expected 值从"人签字"改为"可 trace 到人定的锚点"，signoff 交叉验证，PRD 精度成为硬约束。
- **PRD 模板要求具体例子**：§6.3/§7/§10.4 强制 expected 值，PRD 从"可启动"进一步走向"锚点完整"。

### 代价

- **expected 值错误更晚被抓**：自动签核下，PRD 锚点里的错误 expected 会滑到 QA/REFLECT 才被发现（原来门 1 人签时可能更早）。由 PRD 对齐子代理（BUILD）与 QA 就地补全兜底。
- **trace 的诚实性靠 AI 纪律 + 交叉验证**：AI 可能伪造 `EXPECTED-TRACE`。signoff 的交叉验证（锚点真实存在且值一致）+ PRD 对齐子代理 + REFLECT 提供多层兜底，但不是人逐条看。
- **PRD 写作负担前移**：作者必须写具体例子而非抽象描述。

## 替代方案

- **彻底移除门 1**：PRD 完成后全自动，无升级点。反作弊线纯靠 AI 纪律，范围决策/安全边界无出口，否决。
- **保留人逐项签高风险**：与用户观察（机械翻译不需要人确认）冲突，是重复劳动，否决。

## 相关文件

- `skills/productivity/signoff/SKILL.md`（按需升级门）
- `skills/engineering/test-author/SKILL.md`（expected-trace）
- `skills/engineering/crystallize/SKILL.md`（升级点检查）
- `skills/productivity/story/SKILL.md`（自动链）
- `templates/story/prd.md.template`（§6.3 锚点）
- `design/adr/0005-iterate-fast-converge.md`
- `design/adr/0006-guardrails-and-graded-defense.md`
- `design/test-as-contract-workflow.md`

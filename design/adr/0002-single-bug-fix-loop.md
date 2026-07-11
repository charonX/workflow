# ADR 0002: 合并 file-bug + fix-bugs 为单 bug 人机协同的 /bug，不落本地 bug 工件

## Status

Accepted（2026-07-10 修订：req-gap 从"回流外层"重新定性为"就地补全"，见 Decision 8 与改动记录）

## Context

v0.13 起，工作流在 story 内引入 bug 循环，由两个 skill 承担：`/file-bug`（登记、复现、分类、路由、外部 issue 同步）和 `/fix-bugs`（批量拉取已分类 code-defect、逐个修复、全量回归、输出修复报告）。两者以 `bugs/BUG-NNN.md` 工件为真相源衔接。

实践暴露两个问题：

1. **"AI 独立批量修 bug"的前提不成立。** `/fix-bugs` 在一次自主运行里修完所有 triaged bug、跑全量回归、出报告，bug 之间无人工裁决点。这把 N 个"该不该继续 / 该不该升级回流"的裁决点合并成一个"全绿报告"，系统性绕过了根因诊断与升级闸门。AI 不具有独立修改 bug 的能力--诊断、升级、回流的**裁决**不应自主。

2. **"先提 bug、再另起 skill 修"是多余中转。** 单 bug 人机协同时人本就在场，分类与修复应是一个连续动作。独立的"提 bug"步骤强制做一次 upfront 分类（可能错），而真正的分类信号（3-strike、no-seam）要到修复中才浮现。

参考生态一致支持这个判断。四个成熟调试 skill--gstack `investigate`、agent-skills `debugging-and-error-recovery`、mattpocock `diagnosing-bugs`、superpowers `systematic-debugging`--全部是**单 bug 纪律**，无任何"批量修"先例：

- "Iron Law: NO FIXES WITHOUT ROOT CAUSE"（gstack / superpowers 同款措辞）。
- 3-strike：3 次修复失败 -> 停下问人 / 质疑架构（"3 次失败 = 架构错，不是假设错"）。
- blast-radius：fix 触及 >5 文件 -> AskUserQuestion。
- "no correct seam = 架构即发现" -> 对应我们的 req-gap 就地补全。
- 关键：参考 skill 反对的是 agent 自主**裁决**，不是自主**执行**；它们都是单 skill 从"报告症状"走到"诊断 -> 修复 -> 验证"，且**不落本地 bug 工件**。

## Decision

1. **合并 `/file-bug` + `/fix-bugs` -> `/bug`**（`skills/productivity/bug/`）。一次调用只处理一个 bug：报告症状 -> 诊断根因 -> 分类（inline，人确认裁决）-> 按类别分支（code-defect 修 / test-gap 补测试 / req-gap 就地补全 / not-a-bug 关闭）-> 三道闸门 -> commit -> 停下，把"下一个 bug"的决策交给人。

2. **彻底轻量，不落本地 bug 工件。** 删除 `bugs/` 目录、`bug.md`、`triage.md`、`bug-fix-report.md`。追溯靠测试 `// REQ-TRACE` + commit `[bugfix] BUG-NNN`（BUG-NNN 取自 `workflow-state.yaml` 的 `bug-counter`）。REFLECT 的 bug 指标改为靠 commit log + 人回忆口述。

3. **三道闸门**（参考铁律落地，每个 bug 都过）：
   - **3-strike**：单个 bug 3 次修复尝试仍未让回归测试绿 -> STOP，向用户报告，评估是否 req-gap / 架构错。不准试第 4 次。
   - **blast-radius**：fix 触及 >5 文件 -> AskUserQuestion 确认范围后再继续。
   - **req-gap 检测**：诊断见"REQ 漏了 / 错了"、"HTML UX 参照要改"、"没有正确测试 seam" -> 就地补全 PRD/tech-design/REQ/HTML + 补测试 seam，补完继续修；UX 方向推翻才升级 `/story` 真回流。

4. **分类不再是 upfront 一次性赌注，而是随诊断证据修正。** mattpocock 原话："make the recommendation after the fix is in, not before - you have more information now." 3-strike / no-seam 信号出现时，在同一 skill 内直接重分类为 req-gap 就地补全，不跨 skill 跳。

5. **全量回归时机变更。** `/bug` 只跑该 bug 的回归测试 + 受影响测试，不跑全量。全量由 `/qa-runner` 在收尾时跑（进 REFLECT 前）。与参考 skill 一致：per-bug feedback loop，非 per-bug full suite。

6. **外部 issue tracker 保留，改为实时交互。** issue 是外部记录，不是本地工件。`/bug --from-issue=N` 实时读取 issue（含图片 markdown）作为症状，修复后 `gh issue comment`（中文，不关），用户确认后 `/bug --close-issue=N` 关闭。无本地同步状态文件（去掉 `--sync-comments`、`last-synced-comment-id`）；每次重读 issue 评论。

7. **阶段表简化。** BUG_TRIAGE + BUG_FIX 合并为 `BUG`（13 -> 12 阶段）。`workflow-state.yaml` phase 枚举更新，加 `bug-counter`。旧 story 的 BUG_TRIAGE/BUG_FIX phase 由 `/story` 自动迁移到 BUG。

8. **req-gap 是就地补全（局部纠错），不是回流。**（2026-07-10 修订）bug 中诊断出的 req-gap（REQ/PRD/tech-design 漏或错、缺测试 seam、HTML 参照小改）就地增量更新产物 + 补测试，**phase 保持 BUG**，补完回步骤 5 继续修这个 bug。不退 phase、不归档、不踢回外层重走、不是重新设计。**"回流"严格指 `/story` 的初衷级推翻**（归档重做/删 story），由 `/story` 执行。只有 UX 方向推翻/初衷不成立才升级 `/story` 真回流。这消除了此前"req-gap 回流外层"与 CLAUDE.md"不算回流"的措辞矛盾。

## Consequences

### 正面

- **裁决权回到人手里。** 每个 bug 的分类、升级、回流决策都在人确认下进行，不再被批量报告吞掉。对齐"人持有裁决器"的核心命题。
- **根因诊断成为 first-class。** Iron Law 落地：每个 bug 独立走复现 -> 定位 -> 根因，不再被"跑一遍全量回归就出报告"摊销。
- **req-gap 补全信号不被跳过。** 3-strike / no-seam 直接触发 req-gap 就地补全，而非被当顽固 bug 硬修或跳过。
- **req-gap 不再制造虚假回流。** 就地补全 PRD/tech/测试后继续修，避免把"漏个 case"误当"推翻重来"而退回外层重走整个循环。
- **少一层中转。** 单 skill 吃下整条链，upfront 分类错误可随诊断修正。
- **无本地 bug 工件维护成本。** 不再写/同步 bug.md、triage.md、bug-fix-report.md。

### 负面

- **REFLECT 失去结构化 bug 指标。** bug 总数、类别分布、平均修复轮数等指标依赖 bug 工件，彻底轻量后改为定性回忆。若未来发现需要可量化指标，需重新引入轻量 ledger（与本决策冲突，届时再议）。
- **多 bug story 的人工交互增多。** 每个 bug 一次 `/bug` 调用 + 一次分类确认。这是有意的成本--强制人在场，正是本决策的目的。
- **外部 issue 同步状态不持久。** 去掉 `last-synced-comment-id` 后，每次 `/bug --from-issue` 重读全部评论。对长 issue 评论链有轻微重复读取成本，但省去状态一致性问题。
- **BUG-NNN 编号无工件背书。** 仅存于 commit message 与 `bug-counter`，无法从编号反查结构化根因记录（根因记录已并入 commit / 测试）。
- **req-gap 就地补全在 BUG phase 内改 PRD/tech-design，弱化"phase=当前产物层"的状态机纯度。** 这是有意权衡：把 req-gap 当回流退回外层的代价（中断 bug、重走循环）高于就地补全的语义模糊。phase 保持 BUG 但 history 记补全说明以留痕。

## Alternatives Considered

### Alternative A: 保留两 skill 拆分，仅把 /fix-bugs 改成单 bug + 闸门

- **Rejected**：仍保留"先提 bug 再修"的中转；upfront 分类问题不解决；两个 skill 以 bug 工件衔接的耦合不变。用户明确反馈：单 bug 下"边提边改"即可，参考项目也无独立提 bug 步骤。

### Alternative B: 合并成 /bug，但保留轻量 per-bug 记录（BUG-NNN.md）

- **Rejected**：保留工件就要保留 triage.md / bug-fix-report.md 的衔接、外部 issue 同步状态字段、REFLECT 结构化指标。用户明确选择"彻底轻量，不落 bug 工件"，追溯靠 REQ-TRACE + commit 即可。

### Alternative C: 保留批量 /fix-bugs，仅在 bug 之间加 AskUserQuestion 卡点

- **Rejected**：仍由 agent 持有"bug 列表"并驱动推进，与"AI 不具有独立修改 bug 能力"的判断冲突。闸门卡点在批量框架内是补丁，不如单 bug 单次调用让裁决权彻底回到人手里。

### Alternative D: 连外部 issue 集成一并砍掉

- **Rejected**：外部 issue 是外部记录，不是本地工件，与"彻底轻量"不冲突。issue 作为对话通道是近期投入且有真实价值（跨会话/跨工具跟踪），保留为 `/bug --from-issue` 的实时交互模式。

### Alternative E: req-gap 仍走"回流外层"（退 phase、重新签核、重走循环）

- **Rejected**：把"REQ 漏个 case / tech 文档漏写 / 缺测试 seam"当成推翻重来，退回 THINK/PRD/TECH-DESIGN 重走整个外层循环，代价远高于就地补全。这与 CLAUDE.md 既有定义"REQ 漏 case = 局部纠错、不算回流"矛盾，也违背用户澄清"回流不是重新设计，是更新 PRD/tech 文档 + 补测试；流程上不需要回流"。req-gap 改为就地补全（Decision 8），真回流只留给初衷级推翻。

## Related

- `skills/productivity/bug/SKILL.md`
- `skills/productivity/story/SKILL.md`
- `skills/productivity/reflect/SKILL.md`
- `design/test-as-contract-workflow.md`
- `reference/gstack/investigate/SKILL.md`
- `reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md`
- `reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md`
- `reference/superpowers/skills/systematic-debugging/SKILL.md`
- 取代：v0.13 的 `/file-bug` + `/fix-bugs` 双 skill + `bugs/` 工件设计

## 改动记录

- 2026-07-10：合并 `/file-bug` + `/fix-bugs` 为 `/bug`，单 bug 人机协同，不落本地 bug 工件，三道闸门，外部 issue 实时交互。依据本 ADR。
- 2026-07-10（修订）：req-gap 从"回流外层"重新定性为"就地补全"（局部纠错）--就地更新 PRD/tech-design/REQ/HTML + 补测试，phase 保持 BUG 不退回，补完回步骤 5 继续修。"回流"严格指 `/story` 初衷级推翻（归档重做/删 story）。消除与 CLAUDE.md"不算回流"的矛盾。新增 Decision 8、Alternative E、对应 Consequences。

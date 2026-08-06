# 参考来源：bug

## 理念

bug 处理是一次一个、人机协同的连续动作：报告症状 -> 诊断根因 -> 分类（人确认）-> 修 / 补测试 / 就地补全 / 关闭 -> 验证。`/bug` 把这条链合在一个 skill 里，不拆"提 bug"和"修 bug"，也不落本地 bug 工件。

核心理念来自参考项目的共识：**agent 可自主执行，但裁决（何时停、是否升级、要不要就地补全或升级回流）必须有人在场。** 批量自主修 bug 会把 N 个裁决点合并成一个"全绿报告"，绕过根因诊断与升级闸门；单 bug 单次调用让裁决权回到人手里。

## 借鉴的 reference 文件

- `reference/gstack/investigate/SKILL.md`：单 bug 调查流程、scope freeze、3-strike 规则、blast-radius 闸门（>5 文件 AskUserQuestion）、"3 次失败 = 架构错不是假设错"。
- `reference/agent-skills/skills/debugging-and-error-recovery/SKILL.md`：6 步调试、Stop-the-Line Rule、回归测试要求、"errors compound"。
- `reference/mattpocock/skills/engineering/diagnosing-bugs/SKILL.md`：feedback loop 优先、回归测试先于修复、根因假设外显给人、"make the recommendation after the fix is in"、"no correct seam = 架构即发现"。
- `reference/superpowers/skills/systematic-debugging/SKILL.md`：Iron Law（无 root cause 不修复）、3 次失败回 Phase 1 问人、架构升级路径。

## 主要改动

- 合并 v0.13 的 `/file-bug`（登记/分类/路由）+ `/fix-bugs`（批量修复）为单一 `/bug`。
- **单 bug 单次调用**：一次只处理一个 bug，修完停下，人决定下一个。不批量、不自动连续。
- **诊断优先**（Iron Law）：复现 + 定位根因后才能改代码；根因假设外显给人。
- **分类 inline 且人确认**：code-defect / test-gap / req-gap / not-a-bug 由模型提议、人拍板，随诊断证据可修正。
- **三道闸门**：3-strike / blast-radius(>5 文件) / req-gap 检测。卡住即停问人。
- **不落本地 bug 工件**：删除 `bugs/`、bug.md、triage.md、bug-fix-report.md。追溯靠 `// REQ-TRACE` + commit `[bugfix] BUG-NNN`，BUG-NNN 取自 `workflow-state.yaml` 的 `bug-counter`。
- **全量回归不在 /bug 内跑**：只跑该 bug 回归测试 + 受影响测试；全量由 `/qa-runner` 收尾时跑。
- **外部 issue 实时交互**（非本地同步）：`--from-issue` 实时读取 issue（保留图片 markdown），修复后 `gh issue comment`（中文，不关），`--close-issue` 用户确认后关闭。去掉 `--sync-comments` 与 `last-synced-comment-id`，每次重读 issue 评论。
- req-gap 直接在同一 skill 内就地补全（更新 PRD/tech/REQ/HTML + 补测试），不跨 skill 跳；真回流（初衷级推翻）交 `/story`。

## 未来局部更新建议

- 参考项目更新调试方法时，同步到 `/bug` 诊断步骤与 `/implementer` fix subagent。
- 新增 issue tracker（Linear/Jira）时，扩展 `issue-tracker.json` 和 `/bug --from-issue` 的拉取逻辑。
- 若 REFLECT 发现需要可量化 bug 指标，重新评估是否引入轻量 ledger（与 ADR 0002 的"彻底轻量"冲突，届时另起 ADR）。
- 未来可增加跨 story bug 治理的入口。

## 改动记录

- 2026-07-10：合并 `/file-bug` + `/fix-bugs` 为 `/bug`，单 bug 人机协同，不落本地 bug 工件，三道闸门，外部 issue 实时交互。依据 `design/adr/0002-single-bug-fix-loop.md`。取代 v0.13 的双 skill + `bugs/` 工件设计。
- 2026-07-10（修订）：req-gap 从"回流外层"重新定性为"就地补全"（局部纠错）--就地更新 PRD/tech/REQ/HTML + 补测试，phase 保持 BUG 不退回，补完回步骤 5 继续修。真回流（初衷级推翻）交 `/story`。依据 ADR 0002 修订。
- 2026-08-06：PRD 与 tech-design 合并（`design/adr/0004`）：req-gap 就地补全的产物引用从 PRD/tech-design 改为"PRD（含 §10 技术方案）"。
- 2026-08-06：快速收敛哲学（`design/adr/0005`）：req-gap 定义为**默认收敛路径**（QA 验收缺口 → 就地补 → 继续）；缺口超出当前 story 范围时显式归类（新建 story / 范围外）。

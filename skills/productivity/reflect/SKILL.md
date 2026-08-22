---
name: reflect
description: 最终验收门 + 知识沉淀。QA 全绿且当前 story 无 open bug 后，人做最终验收确认并沉淀经验：更新 engineering-lessons、ADR、STANDARDS、checklists，让下一个 story 的设计上下文更准确。
sources:
  - reference/gstack/retro/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# reflect

## 何时调用

- QA 全绿且当前 story 无 open bug，自动进入 `/reflect`。
- 用户主动说"复盘"、"/reflect"时。

## 输入

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/signoff.md`（Assertion section）
- `.aiassist/stories/<id>/qa-report.md`
- `.aiassist/stories/<id>/browser-verify-report.md`（如有）
- `.aiassist/stories/<id>/workflow-state.yaml`
- `.aiassist/global/adr/`（ADR 目录）
- `.aiassist/global/business-capabilities.md`
- `.aiassist/global/CONTEXT.md`
- `.aiassist/global/architecture.md`（架构概览）
- `.aiassist/global/checklists/`（安全/性能/可访问性/可观测性/测试清单）

## 输出

- `.aiassist/global/engineering-lessons.md`
- `.aiassist/global/adr/`（新增/更新 ADR，标记已取代的 ADR 状态）
- `.aiassist/global/adr/README.md`（ADR 索引更新）
- `.aiassist/global/business-capabilities.md`（更新能力健康指标与测试映射）
- `.aiassist/global/CONTEXT.md`（更新领域术语，如有新共识）
- `.aiassist/global/STANDARDS.md`
- `.aiassist/global/architecture.md`（仅更新高层模块图和 ADR 索引，不承载具体决策）
- `.aiassist/global/checklists/testing.md`
- `.aiassist/global/checklists/security.md`
- `.aiassist/global/checklists/performance.md`
- `.aiassist/global/checklists/accessibility.md`
- `.aiassist/global/checklists/observability.md`
- `.aiassist/stories/<id>/workflow-state.yaml` 最终状态（标记 `status: completed` / `completed: true`，随后整个 story 目录提交删除，进 git 历史）

## 前置条件

进入 `/reflect` 前必须满足：

1. 所有 code-defect bug 已通过 `/bug` 修复并验证。
2. 所有 test-gap 已补测试并通过。
3. 所有 req-gap 已就地补全（PRD/tech/测试）并重新通过 QA。
4. 所有 not-a-bug 已记录决策。
5. 最近一次 QA 全绿（单元 + E2E）。

如果不满足，先回对应阶段处理，不要开始 reflect。

## 执行步骤

1. **最终验收确认**：
   - 展示「最终验收检查清单」给用户。
   - 展示 QA 报告摘要（单元/E2E 结果）。
   - 展示 `browser-verify-report.md` 摘要（如有）。
   - 展示 bug 处理总结（从 `[bugfix]` commit log 回顾本次修了哪些 bug、根因、是否有 req-gap 就地补全）。
   - 展示 signoff 升级点记录（如有）：确认断言阶段的升级项均已解决，或已在 bug 处理中收敛。
   - 用户逐项确认检查清单。
   - 用户明确说"接受"或"完成"。
   - 若用户在验收中发现新的实现偏差，停止 reflect，回到 `/bug` 处理。

2. **统计健康指标**：
   - **bug 处理回顾**（从 `[bugfix]` commit log + 人口述）：本次 bug 数、根因分布、是否有 req-gap 就地补全、哪些 REQ 验收标准在 bug 处理中被发现遗漏
   - 每个阶段耗时/轮数
   - 本 story 是否发生过归档重做(`workflow-state.yaml` 的 `archive` 记录),根因活在哪一层

3. **提炼经验**：
   - 下次应该在哪个阶段多问什么问题
   - 哪些测试模式好用/不好用
   - 哪些架构决策需要记录为 ADR（写入 `adr/`）或已取代旧 ADR（更新状态）
   - 是否有新领域术语或实体定义需要更新到 `CONTEXT.md`
   - 能力地图是否需要调整：新增 capability、合并 entity、更新测试映射
   - **是否产生了可复用的 design pattern**：错误处理、状态管理、API 客户端封装、跨模块调用模式等。如果有，写入 `STANDARDS.md` 或 `engineering-lessons.md`。

4. **更新全局文档**：
   - `engineering-lessons.md`
   - `adr/`：新增 ADR 或更新现有 ADR 状态（如 `superseded`）
   - `adr/README.md`：更新索引
   - `business-capabilities.md`：更新能力健康指标、测试数、覆盖率、最后更新日期
   - `CONTEXT.md`：补充新术语/实体定义
   - `architecture.md`：仅保留高层模块图和 ADR 索引，不写入具体决策
   - `STANDARDS.md`
   - `checklists/`：根据本次 story 的新模式/反模式更新对应清单
     - `testing.md`：新测试模式、反模式、常用断言
     - `security.md`：新威胁、新验证规则
     - `performance.md`：新性能陷阱、新测量方法
     - `accessibility.md`：新 a11y 模式
     - `observability.md`：新 telemetry 模式

5. **完成即清理**（spec 迁出工作区，进 git 历史）：
   - **上提完整性核对**（替代"归档 spec 兜底"）：删除前对照 story 产物，确认意图/决策已全部上提全局文档，有遗漏先补全再删：
     - 架构/技术决策 → `adr/`
     - 能力/实体/REQ→测试映射 → `business-capabilities.md`
     - 领域术语 → `CONTEXT.md`
     - 工程经验/模式 → `engineering-lessons.md` / `STANDARDS.md` / `checklists/`
   - 更新 `workflow-state.yaml`：
     - `phase: REFLECT`
     - `status: completed` / `completed: true`（写后随目录删除，进 git 历史）
     - `completed_at: <date>`
   - **用户显式确认删除**（删除是人触发的判断）：在最终验收清单中确认"本 story 目录将提交删除（含 `ux/`、`design_handoff/`、`workflow-state.yaml`，进 git 历史），确认无遗漏（如 design-handoff 产物已取走）"。
   - **删除**：整个 `.aiassist/stories/<id>/` 目录 `git rm` 并提交（如 `[accept] story <story-id> accepted`），删除提交保留完整证据，需要时 `git show` 回溯。
   - **引用语义（更新后）**：已完成 story 的 spec **不保留**——逻辑真值看代码 + 测试，意图真值看全局文档（`adr/`、`business-capabilities.md`、`CONTEXT.md`、`engineering-lessons.md`、`STANDARDS.md`）；已完成 story 不回流（回流判断只发生在进行中 story）；测试头 `REQ-TRACE` 为历史标签（`<story-id>/<req-id>`），REQ→测试映射以 `business-capabilities.md` 为准。
   - **历史清理（存量 completed story，一并清理）**：顺带检查 `.aiassist/stories/` 下所有 `status: completed` 的旧目录，对每个执行同样的"上提完整性核对 → 补全全局文档 → 用户确认 → `git rm`"，工作区立即只留活动 story。

## 最终验收检查清单

- [ ] 产品在目标环境启动无崩溃。
- [ ] 关键用户流程可走完。
- [ ] 所有发现的 bug 已通过 `/bug` 处理完毕（修复 / 就地补全 / 判定 not-a-bug）。
- [ ] `browser-verify-report.md`（如有）无未处理的 FAIL。
- [ ] QA 报告全绿（单元测试 + E2E）。
- [ ] 实现与已签 REQ 一致（功能层面）。
- [ ] 视觉/feel 层面：如有偏差，已通过 bug 循环处理或记录为可接受偏差。
- [ ] 用户确认：我接受当前实现，可以合并/完成。
- [ ] 用户确认：本 story 目录将提交删除（含 `ux/`、`design_handoff/`、`workflow-state.yaml`，进 git 历史），无遗漏（如 design-handoff 产物已取走）。

## 健康指标

| 指标 | 本期值 | 目标 |
|---|---|---|
| Story 内 bug 数 | N（从 `[bugfix]` commit log 统计） | 随时间下降 |
| 回补 PRD/REQ/ADR 的 bug 数 | N | 越少越好 |
| 实现者轮数 | N | ≤ 5 |
| 单 REQ 平均测试数 | N | ≥ 1 |
| 归档重做次数 | N | 0;>0 说明需求洞察投入不够 |
| 归档根因层 | THINK/PRD/DESIGN | 越靠前越说明一挡体检不够 |

> bug 类别分布、平均修复轮数、视觉/feel 缺陷占比等指标需 bug 工件，彻底轻量下不采集（见 ADR 0002），靠 REFLECT 时人口述。

## 与参考项目的差异

- gstack `retro` 强调团队复盘；我们简化为个人/OPC 经验沉淀。
- superpowers 的 plan 结构给我们的 ADR 格式。
- 核心差异：把单文件 `architecture.md` 拆分为 `adr/` 目录 + `architecture.md` 概览，并维护 `business-capabilities.md` 与 `CONTEXT.md`。
- 本次演进：把 feel-signoff 的验收功能合并到 reflect，用 `/bug` 单 bug 人机协同处理实现偏差（见 `design/adr/0002-single-bug-fix-loop.md`）。

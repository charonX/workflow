---
name: reflect
description: 外层设计循环的反馈。feel-signoff 通过后沉淀本次 story 的经验：更新 engineering-lessons、ADR、STANDARDS，让下一个 story 的设计上下文更准确。
sources:
  - reference/gstack/retro/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# reflect

## 何时调用

`/signoff --stage=feel` 通过，用户说"复盘"、"/reflect"时。

## 输入

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/signoff.md`
- `.aiassist/stories/<id>/qa-report.md`
- `.aiassist/stories/<id>/browser-verify-report.md`（如有）
- `.aiassist/stories/<id>/bug-fix-report.md`（如有）
- `.aiassist/stories/<id>/bugs/`（如有）
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
- `.aiassist/stories/<id>/workflow-state.yaml` 最终状态

## 执行步骤

1. **统计健康指标**：
   - `/signoff --stage=feel` 发现的缺陷数 / 需求变更数
   - **本 story 内 `/file-bug` / `/fix-bugs` 统计**：bug 总数、code-defect / test-gap / req-gap 分布、平均修复轮数、回补文档数
   - 每个阶段耗时/轮数
   - 哪些 REQ 验收标准在 `/signoff --stage=feel` 被发现遗漏
   - 本 story 是否发生过归档重做(`workflow-state.yaml` 的 `archive` 记录),根因活在哪一层
2. **提炼经验**：
   - 下次应该在哪个阶段多问什么问题
   - 哪些测试模式好用/不好用
   - 哪些架构决策需要记录为 ADR（写入 `adr/`）或已取代旧 ADR（更新状态）
   - 是否有新领域术语或实体定义需要更新到 `CONTEXT.md`
   - 能力地图是否需要调整：新增 capability、合并 entity、更新测试映射
   - **是否产生了可复用的 design pattern**：错误处理、状态管理、API 客户端封装、跨模块调用模式等。如果有，写入 `STANDARDS.md` 或 `engineering-lessons.md`。
3. **更新全局文档**：
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
4. **定义下一个阶段切换线（crossing-line）**：如果是多 phase 项目，明确 P2 进入二挡的条件。

## 健康指标

| 指标 | 本期值 | 目标 |
|---|---|---|
| `/signoff --stage=feel` 缺陷率 | N/M | 随时间下降 |
| `/signoff --stage=feel` 需求变更率 | N/M | 随时间下降 |
| Story 内 bug 总数 | N | 随时间下降 |
| Bug 类别分布 | code-defect / test-gap / req-gap | test-gap 和 req-gap 占比下降说明一挡更稳 |
| Bug 平均修复轮数 | N | ≤ 2 |
| 回补 PRD/REQ/ADR 的 bug 数 | N | 越少越好 |
| 实现者轮数 | N | ≤ 5 |
| 单 REQ 平均测试数 | N | ≥ 1 |
| 归档重做次数 | N | 0;>0 说明需求洞察投入不够 |
| 归档根因层 | THINK/PRD/DESIGN | 越靠前越说明一挡体检不够 |

## 与参考项目的差异

- gstack `retro` 强调团队复盘；我们简化为个人/OPC 经验沉淀。
- superpowers 的 plan 结构给我们的 ADR 格式。
- 核心差异：把单文件 `architecture.md` 拆分为 `adr/` 目录 + `architecture.md` 概览，并维护 `business-capabilities.md` 与 `CONTEXT.md`。
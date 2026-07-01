# CLAUDE.md

> **语言约定**：除非用户明确要求使用其他语言，否则所有回复默认使用中文。

本文件为 Claude Code（claude.ai/code）在本仓库工作时的指导手册。

## 工作区定位

这是一个一人创作者/运营者的个人工作流沙盒。`reference/` 目录存放了几个流行的开源 agent-skill 项目，用于学习和借鉴。根工作区是我整理和演进自己 Claude Code 工作流的地方。

从 OPC（一人公司）视角看，高杠杆动作有四步：

1. **需求洞察** —— 确保我们在解决一个真实存在、有人愿意付费的问题。
2. **UI/UX 设计** —— 在写代码之前先把感觉做对。
3. **开发计划** —— 决定做什么、按什么顺序做。
4. **端到端验证** —— 证明交付物对真实用户有用，而不只是代码能跑通。

真正敲代码是低杠杆的。让 agent 负责实现；人的工作是把握愿景、验证需求、审批设计、验收结果。

## 我们的工作流：测试即契约

本工作区现在包含我们自己的 Claude Code 工作流：**测试即契约**（`skills/`）。它融合了参考项目各自的优点：

- **mattpocock skills** —— 传统软件工程纪律（TDD、对抗式文档审查、诊断）。
- **gstack** —— CEO/创始人级别的需求洞察、设计决策、发布与 QA 门禁。
- **soflow** —— 流程驱动的产物链（PRD → REQ → tests → code → reflect）。
- **superpowers** —— 严谨的计划、subagent 驱动的批量执行与审查包。

核心理念：

> **人持有裁决器（断言）；AI 在测试构成的契约内实现。人不直接修改实现代码 —— 他们修改需求和断言，错误逐层回流到最高层。**

关键机制：

- **两挡**：一挡（探索期 —— PRD、HTML 原型、无测试、可随意推翻）→ 跨越线 → 二挡（测试锁定 —— REQ-ID → tests → code）。
- **两道硬签核**：`/assertion-signoff` = 人在实现前签核断言；`/feel-signoff` = 人依据 HTML 参照验收观感。
- **三种角色**：人（REQ/断言/HTML）、test-author agent（编写测试骨架）、implementer agent（编写代码，对测试只读）。
- **REQ-ID 可追溯**：每个测试文件必须声明 `// REQ-TRACE` 和 `// REQ-VERSION`。

除非明确要求，否则不要修改参考仓库。把它们当作只读的灵感来源，把单个 skill 模式复制/适配到 `skills/` 中。

| 路径 | 项目 | 借鉴重点 |
|------|------|----------|
| `reference/gstack/` | Garry's gstack | CEO 洞察、发布与验证：`/office-hours`、`/design-shotgun`、`/qa`、`/benchmark`、`/canary`、`/ship`、浏览器自动化 |
| `reference/mattpocock/` | Matt Pocock's skills | 轻量日常工程技能：`/grill-me`、`/grill-with-docs`、`/tdd`、`/diagnose`、领域建模 |
| `reference/superpowers/` | Jesse's Superpowers | 严谨计划与执行：`writing-plans`、`subagent-driven-development`、`executing-plans` |
| `reference/soflow/` | soflow | 流程驱动的产物链：`.aiassist/stories/<id>/`、PRD → REQ → stories、HTML UX 原型 |
| `reference/baoyu-design/` | baoyu-design（Jim Liu） | Claude Design 可移植 skill：HTML 原型、设计系统、Figma 导入、PPTX 导出、starter components |

## 我们的测试即契约工作流

在实现真实功能时，直接使用 `skills/` 中的 skill，而不是直接调用参考 skill。参考项目只供灵感，`skills/` 才是 operational 工作流。

### 阶段总览

| # | 阶段 | Skill | 触发者 | 目的 |
|---|---|---|---|---|
| 1 | THINK — 需求洞察 | `/demand-insight` | 用户 | 对抗式访谈，暴露隐性需求、边界与矛盾 |
| 2 | PRD 合成 | `/to-prd` | 用户 | 把访谈笔记整理成结构化 PRD |
|   | 设计系统前置 | `/design-system` | 用户 | 在高保真 UX 前建立/校验项目级设计系统 + `tokens.css` |
|   | 设计导入（可选） | `/design-import` | 用户 | 导入设计来源：Figma .fig、GitHub 仓库、现有 HTML/CSS |
| 3 | DESIGN — UX 探索 | `/ux-explore` | 用户 | 用 React 迭代高保真 HTML UX 原型；行为决策 → REQ，视觉决策 → HTML |
| 4 | Crystallize | `/crystallize` | 模型 | 把稳定的 PRD 块转换成带验收标准的 REQ-ID |
| 5 | TEST — 编写靶子 | `/test-author` | 模型 | 从 REQ 生成测试骨架；为人留出占位断言 |
| 6 | assertion-signoff | `/assertion-signoff` | 用户 | 人在实现开始前签核所有断言 |
| 7 | BUILD | `/implementer` | 模型 | 针对测试实现代码；对测试只读；每轮迭代跑全套测试 |
| 8 | REVIEW/QA | `/qa-runner` | 模型 | E2E、回归、证据收集 |
| 9 | feel-signoff | `/feel-signoff` | 用户 | 人依据 HTML 参照验收观感；偏差回流到 REQ |
|   | 开发者交接（可选） | `/design-handoff` | 用户 | 从已批准的 UX 原型生成结构化开发交接包 |
| 10 | REFLECT | `/reflect` | 用户 | 捕获经验教训，更新 `.aiassist/global/` 知识 |

### 在目标项目里启动

1. 确保目标项目已安装本工作流 skill：
   ```bash
   mkdir -p .claude/skills
   cp -R /path/to/workflow/skills/productivity/* .claude/skills/
   cp -R /path/to/workflow/skills/engineering/* .claude/skills/
   cp -R /path/to/workflow/skills/maintenance/* .claude/skills/
   ```
2. 在目标项目里运行 `/bootstrap-workflow`，创建 `.aiassist/` 项目基础设施。
3. 运行 `/test-as-contract`，开始第一个 story。

### 安装 skill

完整的安装与更新说明见 `README.md`。

### 参考工作流（旧版）

下面这份详细的五步参考工作流仍有助于理解高杠杆活动，但实际操作路径已经变成上面的测试即契约 skill 集合。

### 1. 需求洞察 —— 我们在做对的事吗？

在设计和编码之前，先验证问题真实存在、解决方案有人想要。

- 使用 `reference/superpowers/skills/brainstorming/SKILL.md` 或 `reference/gstack/office-hours/SKILL.md` 盘问想法。
- 使用 `reference/skills/skills/productivity/grill-me/SKILL.md` 或 `reference/skills/skills/engineering/grill-with-docs/SKILL.md` 沿决策树每条分支走到底。
- 进入下一阶段前必须回答：
  - 到底是谁在感受这个痛点？
  - 他们今天是怎么做的？
  - 为什么会切换到我们这里？
  - 能最先发布的最窄切口是什么？
- 输出：一份经过验证的简短 spec。如果答案是“我不确定”，就在这里停下来，去访谈用户或做调研。

### 2. UI/UX 设计 —— 它应该是什么感觉？

在写实现计划之前先设计用户体验。

- 使用 `reference/gstack/design-shotgun/SKILL.md` 生成多个视觉变体并比较。
- 如果没有现有设计系统，使用 `reference/gstack/design-consultation/SKILL.md`。
- 使用 `reference/gstack/plan-design-review/SKILL.md` 在动手前从设计维度批判计划。
- 对于线上站点，使用 `reference/gstack/design-review/SKILL.md` 发现并修复视觉/层级问题。
- 输出：已批准的 mockup 或设计方向，以及记录在项目文档中的设计系统决策。

### 3. 开发计划 —— 我们做什么、按什么顺序做？

需求和设计清晰后，写实现计划。不要跳过这一步。

- 以 `reference/superpowers/skills/writing-plans/SKILL.md` 为模板。
- 使用 `reference/gstack/plan-eng-review/SKILL.md` 锁定架构、数据流、边界情况和测试覆盖。
- 保存计划到 `docs/plans/YYYY-MM-DD-<feature-name>.md`。
- 每个任务都应是一个可产出可用、可测试行为的垂直切片。
- 输出：用户批准的计划，包含精确文件路径和验证步骤。

### 4. 实现 —— 让 agent 写代码

有了经过验证的计划，开始执行。目标不是完美代码，而是能跑、能测、符合设计的软件。

- 使用 `reference/superpowers/skills/subagent-driven-development/SKILL.md` 或 `reference/superpowers/skills/executing-plans/SKILL.md` 按任务逐步推进。
- agent 负责编码。我在检查点审查并批准方向变更。
- 如果任务涉及 UI，agent 应产出可运行的状态，而不只是代码。
- 不要陷入重构循环。YAGNI。发布能验证需求的最小版本。

### 5. 端到端验证 —— 它真的有用吗？

这是最高杠杆的一步。验证真实用户体验，而不只是单元测试。

- **功能验证**：运行 app/CLI/站点，走一遍真实用户流程。如果对真实用户不可用，就不发布。
- **自动化测试**：运行项目的测试/ lint / typecheck 命令。发布前修复回归。
- **QA / 自测**：使用 `reference/gstack/qa/SKILL.md` 或 `reference/gstack/qa-only/SKILL.md` 系统化测试流程并截图/收集证据。
- **浏览器/站点验证**：使用 `reference/gstack/browse/` 对部署或本地站点进行端到端交互。
- **性能**：如果加载时间或包大小重要，使用 `reference/gstack/benchmark/SKILL.md`。
- **发布后**：使用 `reference/gstack/canary/SKILL.md` 在发布后监控生产环境。
- 输出：已发布的东西，以及证明它对用户有效的证据。

## Skill 速查

### 我们自己的 skill（`skills/`）

| 我想…… | 使用 |
|--------|------|
| 用测试即契约启动新功能 | `/test-as-contract` |
| 在目标项目初始化工作流 | `/bootstrap-workflow` |
| 运行对抗式需求访谈 | `/demand-insight` |
| 把讨论整理成 PRD | `/to-prd` |
| 用 HTML 原型探索 UX | `/ux-explore` |
| 建立或更新设计系统 | `/design-system` |
| 导入设计来源（Figma/GitHub/HTML） | `/design-import` |
| 把 PRD 转成 REQ-ID | `/crystallize` |
| 从 REQ 生成测试骨架 | `/test-author` |
| 在实现前签核断言 | `/assertion-signoff` |
| 针对已签核测试实现代码 | `/implementer` |
| 运行 QA / E2E / 回归 | `/qa-runner` |
| 依据 HTML 参照验收观感 | `/feel-signoff` |
| 从 UX 生成开发者交接包 | `/design-handoff` |
| 捕获经验教训并更新知识 | `/reflect` |
| 同步参考项目并吸收上游变更 | `/sync-refs` |

### 参考 skill（仅作灵感）

| 我想…… | 参考 |
|--------|------|
| 验证想法或找到切口 | `reference/superpowers/skills/brainstorming/` 或 `reference/gstack/office-hours/` |
| 把计划盘问到锋利 | `reference/mattpocock/skills/productivity/grill-me/` 或 `reference/mattpocock/skills/engineering/grill-with-docs/` |
| 探索 UI 变体 | `reference/gstack/design-shotgun/` |
| 从零建立设计系统 | `reference/gstack/design-consultation/` |
| 在编码前审查计划的设计维度 | `reference/gstack/plan-design-review/` |
| 审计线上站点视觉设计 | `reference/gstack/design-review/` |
| 写结构化实现计划 | `reference/superpowers/skills/writing-plans/` |
| 审查架构 / 边界情况 | `reference/gstack/plan-eng-review/` |
| 在 agent 支持下执行计划 | `reference/superpowers/skills/subagent-driven-development/` |
| 调试 bug | `reference/skills/skills/engineering/diagnose/` 或 `reference/gstack/investigate/` |
| 系统化 QA 站点 | `reference/gstack/qa/` 或 `reference/gstack/qa-only/` |
| 检查性能 | `reference/gstack/benchmark/` |
| 发布后监控 | `reference/gstack/canary/` |
| 发布 / 开 PR | `reference/gstack/ship/` + `reference/gstack/review/` |

## 参考项目命令

这些命令要在对应 `reference/` 子目录下运行，不要在工作区根目录运行。

### gstack（`reference/gstack/`）
- `bun install` —— 安装依赖
- `bun test` —— 免费测试
- `bun run test:evals` —— 付费 evals，基于 diff
- `bun run build` —— 生成文档 + 编译二进制
- `bun run gen:skill-docs` —— 从模板重新生成 SKILL.md
- `bun run slop` / `bun run slop:diff` —— AI 代码质量扫描

### superpowers（`reference/superpowers/`）
- 没有根构建。在创建或编辑 skill 前，先阅读 `skills/writing-skills/SKILL.md`。

### mattpocock skills（`reference/mattpocock/`）
- `npx skills@latest add mattpocock/skills` —— 消费者安装
- Skill 位于 `skills/<bucket>/<skill-name>/SKILL.md`。

## 创建与更新我们的 skill

`skills/` 是测试即契约 skill 的 canonical 集合，按 Claude Code 插件组织：

- `skills/productivity/` —— 用户触发的工作流 skill
- `skills/engineering/` —— 模型触发的实现 skill
- `skills/maintenance/` —— 工作流维护 skill（同步 refs、更新配置等）

把参考 skill 模式适配到我们工作流时：

1. 只把需要的模式复制到新文件夹 `skills/<bucket>/<skill-name>/SKILL.md`。
2. 把 skill 路径加到 `.claude-plugin/plugin.json`。
3. 在 skill 前言的 `sources:` 和 `skills/<bucket>/<skill-name>/SOURCES.md` 中记录参考来源。
4. 删掉不适合我们工作流的内容。
5. 调整语气和示例，使其符合我们的项目。
6. 在真实 Claude Code 会话中测试该 skill，再定稿。

好的 skill 小而可组合。一个 skill = 一个清晰的职责。

当参考项目更新时，使用记录的 `sources` 在本地 diff 并更新我们的 skill，然后重新安装到目标项目。

## 与参考项目保持同步

我们的 skill 借鉴自参考项目（`reference/`）。当这些项目更新时，我们需要结构化地判断吸收哪些变更。

### 快速同步

运行 `/sync-refs`（或 `./scripts/sync-refs.sh`）。它会：

1. 对所有参考仓库执行 `git pull`
2. 解析每个 skill 的 `SOURCES.md`，找到它依赖的参考文件
3. 对每个依赖执行 `git log --since=<last sync>`
4. 生成 `docs/sync-reports/YYYY-MM-DD.md`，按 skill 分组列出变更
5. 引导你逐个判断：吸收 / 跳过 / 延后

### 手动同步

```bash
# 1. 拉取所有参考仓库
./scripts/sync-refs.sh --pull-only

# 2. 查看某个参考文件的变更
git -C reference/baoyu-design log --since="2026-06-01" -- skills/baoyu-design/system-prompt.md

# 3. Diff 变更
git -C reference/baoyu-design diff <old-commit>..HEAD -- skills/baoyu-design/system-prompt.md

# 4. 如果吸收，更新 skill 及其 SOURCES.md
```

### 更新节奏

- **每月**（默认）：运行 `/sync-refs`，大多数报告会是干净的
- **大版本发布时**：gstack/superpowers/baoyu-design 发布主版本时
- **重大工作流变更前**：检查上游是否已经解决了同样的问题

### 决策框架

| 参考变更类型 | 动作 |
|-------------|------|
| 我们不使用的新功能/skill | 跳过 |
| 我们已借鉴部分的方法论改进 | 仔细评估，通常值得吸收 |
| bug 修复或格式改进 | 吸收（低风险） |
| 内部重构 | 跳过（不影响方法论） |
| 上游文件移动/删除 | 标记 —— 检查我们的参考是否断裂 |
| 与我们的改编冲突的变更 | 分析 —— 除非上游找到了更好的方案，否则保留我们的设计决策 |

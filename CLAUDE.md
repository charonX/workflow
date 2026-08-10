# CLAUDE.md

> **如果你是为本仓库工作的 AI Agent，先读这一段。**
>
> 本仓库是 `loop-workflow`（循环工作流）的 canonical 源码和实验沙盒。你的任务不是“帮用户实现某个功能”，而是维护/演进一套**可复用的 Claude Code skill 集合**。最昂贵的错误是：把 skill 当成一次性脚本写、直接修改 `reference/` 里的参考仓库、或者在没有 plan 的情况下改动核心工作流。不确定时，停下来用 plan mode 或 AskUserQuestion，而不是猜测。

---

## 语言约定

除非用户明确要求使用其他语言，否则所有回复默认使用**中文**。

Skill 文件名、代码中的标识符、注释中的专业术语（如 `REQ-TRACE`、`workflow-state.yaml`）保持英文，不要翻译。

## 工作区定位

这是一个一人创作者/运营者的个人工作流沙盒，同时是 `loop-workflow` 插件的 canonical 源码。

| 目录 | 用途 | 能否修改 |
|---|---|---|
| `skills/` | 我们自己的 Claude Code skill 集合（canonical） | 能，按本文件纪律 |
| `templates/` | skill 使用的全局/ story 级模板 | 能，按本文件纪律 |
| `design/` | 工作流理念的推导文档 | 能，但需经过反思 |
| `reference/` | 流行开源 agent-skill 项目的只读副本 | **不能**，只供灵感 |
| `scripts/` | 维护脚本（如 `sync-refs.sh`） | 能 |
| `.aiassist/` | **不在本仓库**；目标项目初始化后的产物 | 不能在这里创建 |

真正敲代码是低杠杆的。让 agent 负责实现；人的工作是把握愿景、验证需求、审批设计、验收结果。本仓库的“产品”就是这套工作流本身。

## 项目结构

```
.
├── skills/
│   ├── productivity/          # 用户触发的工作流 skill
│   │   ├── story/             # 循环总入口
│   │   ├── bootstrap-workflow/# 初始化目标项目基础设施
│   │   ├── demand-insight/
│   │   ├── to-prd/
│   │   ├── domain-model/      # 维护 CONTEXT.md
│   │   ├── tech-design/       # 条件深潜（仅 complex story），写入 prd.md §10
│   │   ├── design/
│   │   ├── bug/               # 单 bug 人机协同处理
│   │   ├── review/
│   │   ├── signoff/
│   │   ├── design-handoff/
│   │   ├── reflect/
│   │   └── research/
│   ├── engineering/           # 模型触发（agent 自治）的实现 skill
│   │   ├── crystallize/       # PRD -> REQ-ID
│   │   ├── test-author/       # 生成业务测试骨架
│   │   ├── implementer/       # 针对测试实现代码
│   │   ├── qa-runner/
│   │   ├── browser-verify/    # 运行时浏览器验证（DevTools MCP）
│   │   └── tdd/               # 内层 RED -> GREEN 纪律
│   └── maintenance/           # 工作流维护 skill
│       └── sync-refs/
├── templates/
│   ├── claude/                # 追加到目标项目 CLAUDE.md 的附录
│   ├── global/                # .aiassist/global/ 初始化模板（含 checklists/）
│   ├── story/                 # .aiassist/stories/<id>/ 初始化模板
│   ├── hooks/                 # git hooks
│   └── github/workflows/      # CI/CD contract-gate 模板
├── design/                    # 工作流设计文档（理念的源头）
├── reference/                 # 只读参考仓库（见下）
├── scripts/
│   └── sync-refs.sh
├── README.md
├── CLAUDE.md                  # 本文件
└── .claude-plugin/
    └── plugin.json            # skill 注册表
```

## 工作纪律

### 绝对不要

1. **不要修改 `reference/` 下的任何参考仓库**。它们是只读灵感来源。想把某个模式适配到我们的工作流，复制到 `skills/` 的新文件夹，并在 `SOURCES.md` 中标注来源。
2. **不要把 skill 写成一次性脚本**。每个 skill 必须是清晰、可复用的工作流步骤，前言有 `sources:`，目录下有 `SOURCES.md`。
3. **不要在没有 plan mode 的情况下开始非 trivial 改动**。新增 skill、重构工作流、改动签核机制等，必须先获得用户批准的 plan。
4. **不要在一个 commit 里混实现代码和测试文件**。本工作流有 git hooks 拦截，但纪律优先于工具。
5. **不要改完不验证**。改动 `plugin.json` 后验证 JSON；改动 skill 后确认路径存在；改动附录后检查与 `README.md` 一致。

### 必须做

1. **新增 skill 必须同步 `plugin.json`**，并在 skill 前言的 `sources:` 和 `SOURCES.md` 中记录参考来源。
2. **修改核心工作流机制时，先考虑是否需要 ADR**。满足“难逆转、不说明会令人困惑、有真实取舍”的决策，写入 `.aiassist/global/adr/`（本仓库则写入 `design/` 或 `adr/` 目录，视范围而定）。
3. **保持术语一致**。使用本工作流定义的词汇：循环、外层/内层循环、稳定块/移动块、签核门、seam、capability/entity、回流等。
4. **关键决策留证据**。重要的拒绝、方案选择、范围变更，应简要说明理由，不要只给结论。

## 我们的循环工作流

本工作流以“测试即契约”为内核：

> **人持有裁决器（断言）；AI 在测试构成的契约内实现。人不直接修改实现代码 -- 他们修改需求和断言，错误逐层回流到最高层。**

测试全绿是实现的**必要门槛，不是充分条件**。实现还必须对齐 PRD 意图、`prd.md` 技术方案（§10）的模块/数据流/接口契约、以及 UX HTML 的结构与行为。禁止为通过测试而写特判、mock 掉真实行为、或阉割功能。

每个 REQ 必须至少有一个自动化测试。不能自动化的纯审美判断（颜色、间距、动效曲线）才允许进入 REFLECT 人工验收。涉及元素存在、状态变化、路由跳转、API 调用的行为，必须在进入 BUILD 前就有自动化契约。

**快速收敛**：PRD 不可能一次全面（见 `design/adr/0005`）。PRD 只需"可启动"（稳定块+主流程+复杂度）；缺口在 to-prd 对话 / review 阶段就地补，补不了必须显式归类（就地补 / 移动块 / 新建 story / 范围外），不许悬空。QA 验收发现的缺口走 `/bug` req-gap **就地补全**收敛——这是默认收敛路径，不是异常。实现前签核收敛到**高风险项**（初衷、跨模块契约、expected 值、安全边界），其余由 AI 自检。

### 两个循环

- **外层循环（人控制）**：需求洞察 -> PRD -> UX -> 领域建模 -> 技术方案 -> REQ -> 断言签核 -> (BUILD -> QA -> bug 循环) -> REFLECT -> 回流。
- **内层循环（agent 控制）**：读测试 -> 写代码 -> 跑测试 -> 改 bug -> 全绿。

两个循环的边界是**签核**：

| 门 | Skill | 作用 |
|---|---|---|
| 门 1 | `/signoff --stage=assertion` | 人在实现前签核高风险断言，把上下文交给 AI |
| 门 2 | `/reflect` | QA 全绿、bug 循环结束后，人做最终验收确认并沉淀知识 |

### 阶段总览

| # | 阶段 | Skill | 触发者 | 所属循环 | 目的 |
|---|---|---|---|---|---|
| 0 | WAYFIND - 探索（可选） | `/wayfind` | 用户 | 外层（story 上游） | 模糊想法 → 决策票 → 清晰的 story 列表/ADR |
| 1 | THINK - 需求洞察 | `/demand-insight` | 用户 | 外层 | 对抗式访谈，暴露隐性需求、边界与矛盾 |
| 2 | PRD 合成 | `/to-prd` | 用户 | 外层 | 把访谈笔记整理成结构化 PRD（含 §10 技术方案、§11 测试决策） |
| 3 | DESIGN - 设计 | `/design` | 用户 | 外层 | 统一入口：建/更新设计系统、导入设计源、迭代 HTML-native 高保真原型 |
| 4 | DOMAIN-MODEL - 领域建模 | `/domain-model` | 用户 | 外层 | 统一术语与业务实体，维护 `CONTEXT.md` |
| 5 | TECH-DESIGN - 技术方案（**仅 complex**） | `/tech-design` | 用户 | 外层 | 对抗式深潜模块边界、数据流、接口契约与 CLI 优先的测试 seams，写入 `prd.md` §10；`simple` story 跳过，直接结晶 |
| 6 | CRYSTALLIZE - 结晶 | `/crystallize` | 模型 | 外层 | 把稳定的 PRD 块转换成带验收标准的 REQ-ID；每个 REQ 至少一个自动化测试；PRD 缺口对话确认归类（就地补/移动块/新 story/范围外），不阻断 |
| 7 | TEST - 编写靶子 | `/test-author` | 模型 | 外层 | 从 REQ 优先生成 CLI 测试骨架；前端需求强制生成组件/浏览器结构行为测试；浏览器 E2E 默认 Playwright；不能自动化的行为才允许在 REFLECT 中人工验收 |
| 8 | ASSERTION-SIGNOFF - 断言签核 | `/signoff --stage=assertion` | 用户 | **门 1** | 人在实现开始前签核高风险断言（初衷、跨模块契约、expected 值、安全边界）；其余 AI 自检；把上下文交给 AI |
| 9 | BUILD - 实现 | `/implementer` | 模型 | 内层 | 默认用子代理实现每个切片；父代理读文档/调度/验证；对业务测试只读；内部用 `/tdd` 纪律 RED -> GREEN；每个 slice 绿后由 refactor subagent 做一轮安全重构；每轮迭代跑全套业务测试 |
| 10 | QA - 回归 | `/qa-runner` | 模型 | 内层 | E2E、回归、证据收集；浏览器 E2E 默认 Playwright；失败时建议 `/bug`；浏览器项目在 E2E 通过后可选调用 `/browser-verify` 做运行时验证；无 open bug 后进入 REFLECT |
| 11 | BUG - 缺陷处理 | `/bug` | 用户 | 内层/外层交界 | 单 bug 人机协同：诊断根因 -> 分类（人确认）-> 修/补测试/就地补全/关闭；三道闸门（3-strike/blast-radius/req-gap）；不落 bug 工件；支持从外部 issue 实时拉取 |
| 12 | REFLECT - 反思 | `/reflect` | 用户 | **门 2** | QA 全绿、bug 处理结束后，人做最终验收确认并沉淀知识 |
| - | 开发者交接（可选） | `/design-handoff` | 用户 | 外层 | 从已批准的 UX 原型生成结构化开发交接包（含机器可读 manifest） |

### 关键机制

- **两挡**：一挡（探索期 -- PRD、HTML 原型、无测试、可随意推翻）-> 跨越线 -> 二挡（测试锁定 -- REQ-ID -> tests -> code）。
- **三道角色权限互斥**：人写 REQ/断言/HTML；test-author 写测试骨架；implementer 写实现代码且对业务测试只读。
- **REQ-ID 可追溯**：每个测试文件必须声明 `// REQ-TRACE` 和 `// REQ-VERSION`。
- **能力/实体可追溯**：每个 REQ 标注 `capability` 和 `entity`，测试头部声明 `// CAPABILITY-TRACE` 和 `// ENTITY-TRACE`，测试按 `tests/capabilities/<capability>/<entity>/` 组织。
- **ADR 目录**：重要架构决策写入 `.aiassist/global/adr/`，原 `architecture.md` 只保留高层概览和索引。
- **共享检查清单**：`bootstrap-workflow` 初始化 `.aiassist/global/checklists/`（testing/security/performance/accessibility/observability），由 `/reflect` 根据 story 经验持续更新；`/tech-design`、`/review`、`/test-author` 等 skill 按需引用。
- **CLI 是默认 seam**：能用产品 CLI 验证的行为不进浏览器 E2E；不能 CLI 化的退到 public 接口测试或浏览器 E2E。
- **四道承重墙不可配置**（见 `design/adr/0006-guardrails-and-graded-defense.md`）：测试前置（REQ→测试在实现前锁）、实现者对测试只读、PRD 对齐子代理（测试全绿 ≠ 意图落地）、初衷锚点（问题陈述是回流基准）。任何 skill 不得绕过。
- **bug 处理单 bug 人机协同**：`/bug` 一次一个，诊断根因 -> 分类（人确认）-> 三道闸门 -> commit -> 停下。不批量、不落 bug 工件（见 `design/adr/0002-single-bug-fix-loop.md`）。

### 回流机制

工作流承认一挡会推翻。`/story` 内置回流分支。

**核心：story = 初衷。** 初衷指向用户痛点，不是具体方案。

| 情况 | 动作 |
|---|---|
| 初衷不变，实现路径错了（一挡/二挡都算） | 同 story 下 `archive/` 归档本次尝试，同 story 重做 |
| 初衷本身错了/痛点不成立 | 不归档，直接删 story |

- **归档范围**：PRD、requirements、断言签核、代码等承诺层产物 + `reason.md`（根因+推翻理由）。UX 原型不归档（一挡思考工具，直接改）。
- **根因诊断优先**：回流前先判“初衷在不在”。模型提议，人拍板。
- **不算回流的情况**（走局部纠错）：QA 验收发现 req-gap（REQ/PRD 漏或错、缺测试 seam、HTML 参照小改）——**默认收敛路径**，`/bug` 就地补全 PRD（含 §10 技术方案）/REQ/测试（REQ 漏 case 走 `/crystallize`），继续修；缺口超出当前 story 范围则显式归类（新建 story / 范围外）；断言自相矛盾 -> 门 1 重审；一挡内单块推翻 -> 该块降级回“移动块”。

## Skill 速查

### 我们自己的 skill（`skills/`）

| 我想…… | 使用 |
|--------|------|
| 探索一个模糊想法，搞清楚该做哪些事（story 之前的上游探索） | `/wayfind` |
| 用循环启动新功能 / 继续一个 story（路由外层/内层循环、回流） | `/story` |
| 发现根本问题，要回流（归档重做/删 story） | `/story`（回流分支） |
| 在目标项目初始化工作流 | `/bootstrap-workflow` |
| 运行对抗式需求访谈，用第一性原理剥离继承假设 | `/demand-insight` |
| 把讨论整理成 PRD | `/to-prd` |
| 用 HTML 原型探索 UX（含编译 preview、资产版本管理、变体） | `/design` |
| 建立或更新设计系统 | `/design` |
| 导入设计来源（Figma/GitHub/HTML） | `/design` |
| 在当前 story 内单 bug 人机协同处理：诊断根因 -> 分类（人确认）-> 修/补测试/就地补全/关闭；支持从外部 issue 拉取 | `/bug` |
| 统一领域术语与业务实体，维护 `CONTEXT.md` | `/domain-model` |
| 做对抗式技术方案深潜（仅 complex story），写入 `prd.md` §10 | `/tech-design` |
| 把 PRD 转成 REQ-ID（每个 REQ 至少一个自动化测试） | `/crystallize` |
| 从 REQ 优先生成 CLI 测试骨架；前端需求强制生成组件/浏览器结构行为测试；浏览器 E2E 默认 Playwright | `/test-author` |
| 内层实现纪律：RED -> GREEN 写单元测试 | `/tdd` |
| 在实现前签核高风险断言 | `/signoff` |
| 针对已签核测试实现代码（默认子代理实现，父代理调度验证） | `/implementer` |
| 运行 QA / E2E（Playwright）/ 回归；浏览器项目可触发 `/browser-verify` 收集运行时证据 | `/qa-runner` |
| 用 Chrome DevTools MCP 做运行时浏览器验证，输出客观证据供 bug 循环和 REFLECT 参考 | `/browser-verify` |
| 从 UX 生成开发者交接包 | `/design-handoff` |
| 捕获经验教训并更新知识 | `/reflect` |
| 针对技术/API/库问题做带引用的调研 | `/research` |
| 手动审查 PRD/技术方案/代码；`--stage=code --mode=panel` 启用 specialist 子代理并行审查 | `/review` |
| 同步参考项目并吸收上游变更 | `/sync-refs` |

### 参考 skill（仅作灵感）

| 我想…… | 参考 |
|--------|------|
| 验证想法或找到切口 | `reference/superpowers/skills/brainstorming/` 或 `reference/gstack/office-hours/` |
| 把计划盘问到锋利 | `reference/mattpocock/skills/productivity/grilling/` 或 `reference/mattpocock/skills/engineering/grill-with-docs/` |
| 生产级需求访谈（置信度 + GUESS） | `reference/agent-skills/skills/interview-me/` |
| 探索 UI 变体 | `reference/gstack/design-shotgun/` |
| 从零建立设计系统 | `reference/gstack/design-consultation/` |
| 在编码前审查计划的设计维度 | `reference/gstack/plan-design-review/` |
| 审计线上站点视觉设计 | `reference/gstack/design-review/` |
| 写结构化实现计划 | `reference/superpowers/skills/writing-plans/` |
| 审查架构 / 边界情况 | `reference/gstack/plan-eng-review/` |
| 多维度 specialist 代码审查 | `reference/agent-skills/agents/code-reviewer/`、`security-auditor/`、`test-engineer/`、`web-performance-auditor/` |
| 在 agent 支持下执行计划 | `reference/superpowers/skills/subagent-driven-development/` |
| 调试 bug | `reference/mattpocock/skills/engineering/diagnose/` 或 `reference/gstack/investigate/` |
| 内层 TDD 纪律、测试金字塔、DAMP、Prove-It | `reference/agent-skills/skills/test-driven-development/` |
| 增量实现纪律（Simplicity First、Scope Discipline、Feature Flags） | `reference/agent-skills/skills/incremental-implementation/` |
| 系统化 QA 站点 | `reference/gstack/qa/` 或 `reference/gstack/qa-only/` |
| 浏览器运行时验证（DevTools MCP）| `reference/agent-skills/skills/browser-testing-with-devtools/` |
| 检查性能 | `reference/gstack/benchmark/` |
| 发布后监控 | `reference/gstack/canary/` |
| 发布 / 开 PR | `reference/gstack/ship/` + `reference/gstack/review/` |

## 创建与更新 skill

把参考 skill 模式适配到我们工作流时：

1. 只把需要的模式复制到新文件夹 `skills/<bucket>/<skill-name>/`。
2. 把 skill 路径加到 `.claude-plugin/plugin.json`。
3. 在 skill 前言的 `sources:` 和 `skills/<bucket>/<skill-name>/SOURCES.md` 中记录参考来源。
4. 删掉不适合我们工作流的内容。
5. 调整语气和示例，使其符合我们的项目。
6. 在真实 Claude Code 会话中测试该 skill，再定稿。

好的 skill 小而可组合。一个 skill = 一个清晰的职责。

当参考项目更新时，使用记录的 `sources` 在本地 diff 并更新我们的 skill，然后重新安装到目标项目。

## 与参考项目保持同步

运行 `/sync-refs`（或 `./scripts/sync-refs.sh`）。它会：

1. 对所有参考仓库执行 `git pull`
2. 解析每个 skill 的 `SOURCES.md`，找到它依赖的参考文件
3. 对每个依赖执行 `git log --since=<last sync>`
4. 生成 `docs/sync-reports/YYYY-MM-DD.md`，按 skill 分组列出变更
5. 引导你逐个判断：吸收 / 跳过 / 延后

## 常用命令

```bash
# 验证插件配置
python3 -m json.tool .claude-plugin/plugin.json

# 拉取所有参考仓库（只读）
./scripts/sync-refs.sh --pull-only

# 手动安装 skill 到目标项目（见 README.md 完整说明）
cd /path/to/your-project
cp -R /path/to/workflow/skills/productivity/* .claude/skills/
cp -R /path/to/workflow/skills/engineering/* .claude/skills/
cp -R /path/to/workflow/skills/maintenance/* .claude/skills/
```

## 声音与风格

- **冷静、结构化、不推销**。skill 正文用清晰的步骤、表格、清单，避免营销式形容词。
- **中文回复，英文术语**。如“使用 `/crystallize` 生成 REQ-ID”。
- **关键决策显性化**。用 plan mode 或 AskUserQuestion，不替用户做重大取舍。
- **错误向上回**。发现测试、需求、方案错了，回到最高出错层修，不在低层打补丁。

## 常见错误与升级路径

| 错误 | 正确做法 |
|---|---|
| 直接改 `reference/` | 复制模式到 `skills/`，写 `SOURCES.md` |
| 没 plan 就改核心流程 | 先进入 plan mode，获得用户批准 |
| 新增 skill 不同步 `plugin.json` | 同步注册，并验证 JSON |
| 把业务逻辑写进 skill | skill 是工作流步骤，不是产品功能实现 |
| 不确定用户意图时猜测 | 用 AskUserQuestion 澄清 |

如果计划 Approved 后发现涉及跨 skill 结构性改动（例如改动签核机制、改变测试组织方式），先回到 plan mode 更新方案，而不是边做边改。

## 验收测试

改动本仓库后，至少验证：

1. `.claude-plugin/plugin.json` 是有效 JSON。
2. `plugin.json` 中列出的每个 skill 目录在 `skills/` 下真实存在。
3. `CLAUDE.md` 与 `README.md` 的 skill 列表、阶段数量一致。
4. 新增 skill 有 `SOURCES.md`。
5. `templates/claude/project-claude-appendix.md.template` 中的产物目录与 `bootstrap-workflow/SKILL.md` 一致。

## 参考项目命令

这些命令要在对应 `reference/` 子目录下运行，不要在工作区根目录运行。

### gstack（`reference/gstack/`）
- `bun install` -- 安装依赖
- `bun test` -- 免费测试
- `bun run test:evals` -- 付费 evals，基于 diff
- `bun run build` -- 生成文档 + 编译二进制
- `bun run gen:skill-docs` -- 从模板重新生成 SKILL.md
- `bun run slop` / `bun run slop:diff` -- AI 代码质量扫描

### superpowers（`reference/superpowers/`）
- 没有根构建。在创建或编辑 skill 前，先阅读 `skills/writing-skills/SKILL.md`。

### mattpocock skills（`reference/mattpocock/`）
- `npx skills@latest add mattpocock/skills` -- 消费者安装
- Skill 位于 `skills/<bucket>/<skill-name>/SKILL.md`。

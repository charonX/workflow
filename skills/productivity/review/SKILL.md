---
name: review
description: 外层循环中的手动检查点。一次调用按 cover 层并行派发 specialist 子代理审查（PRD/技术方案/REQ/测试/代码），汇总一份 review.md 报告；建议在 QA 全绿后、REFLECT 前做末端统一审查。不自动修改产物。
sources:
  - reference/gstack/review/SKILL.md
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/mattpocock/skills/engineering/code-review/SKILL.md
  - reference/agent-skills/agents/code-reviewer.md
  - reference/agent-skills/agents/security-auditor.md
  - reference/agent-skills/agents/test-engineer.md
  - reference/agent-skills/agents/web-performance-auditor.md
  - workflow/design/test-as-contract-workflow.md
---

# review

## 何时调用

人在某个（或所有）审查层完成后，觉得"需要一双新眼睛看看"时，手动触发。**默认建议在 QA 全绿后、REFLECT 前做一次末端统一审查**——一次审全链（PRD + 技术方案 + REQ + 测试 + 代码），因为此时五层产物全部存在。

```
/review                                       # 默认：审查所有输入已存在的层（末端 = 全链）
/review --cover=req,test --story=<story-id>   # 聚焦：只审自动链产物（REQ + 测试）
/review --cover=code                          # 聚焦：只审实现 diff
```

- `--cover`：可选，逗号分隔要审查的层：`prd` / `tech` / `req` / `test` / `code`。默认自动 = 审查所有输入已存在的层。
- `--mode`：可选，`panel`（默认，并行派发 specialist 子代理）/ `single`（单会话轻量审查，不派子代理）。
- `--story`：可选，默认取最近更新的 story。

**建议在新 Claude Code 会话中调用**，避免当前会话的上下文偏见影响审查效果。

## 两种模式

### Panel 模式（默认）：并行 specialist 审查

- 按 `--cover` 确定的层，并行派发对应 specialist 子代理，每个审一个层/维度。
- 父代理等待所有子代理返回，汇总到 `review.md`。
- 适合：末端统一审查、关键/高风险变更、需要多视角。

### Single 模式：`--mode=single`

- 不派子代理，在当前会话中按各层审查维度逐项过一遍。
- 适合：小改动、快速复查、token 敏感场景。

## 设计原则

- **手动触发**：不是每个 story 的必经环节，由人判断是否需要。
- **新会话友好**：skill 自己读取所有需要文件，不依赖调用会话的上下文。
- **建议性而非强制性**：输出审查报告，人不一定要修复所有问题，但必须显性决策。
- **回流到人决定**：报告可以建议回流，但执行回流由人通过 `/story` 完成。

## Cover → Specialist 子代理

父代理按 `--cover` 解析要审的层，为每层派发一个 specialist。每个子代理只审本层，不跨维度重复审查。

| cover | 子代理 | 输入 | 审查维度 |
|---|---|---|---|
| `prd` | **prd-reviewer** | `prd.md` + `workflow-state.yaml` + `CONTEXT.md` | 痛点锚定（§1 问题陈述仍是用户痛点）；稳定/移动块划分；**§6.3/§7/§10.4 预期值锚点完整性**（每个稳定块有具体例子）；GAP 归类（§14 无悬空）；用户故事覆盖主路径和边界 |
| `tech` | **tech-reviewer** | `prd.md` §10-11 + `.aiassist/global/adr/` + `CONTEXT.md` | §10 模块/数据流覆盖所有稳定块；模块职责单一；跨模块接口契约四要素（输入/输出/错误/副作用）；测试 seams（§11.1 CLI 优先）；复杂度是否过度设计；§10.6 风险与回流点；ADR 覆盖与冲突；术语一致 |
| `req` | **req-reviewer** | `requirements.md` + `prd.md` + `business-capabilities.md` + `CONTEXT.md` | 每个 PRD 稳定块 → 至少一个 REQ；REQ 无孤儿（都能回溯到稳定块）；**验收标准 ↔ PRD §6.3/§7/§10.4 锚点一致**；capability/entity 与能力地图一致；REQ-ID 格式与哈希 |
| `test` | **test-engineer** | 测试文件 + `requirements.md` + `test-plan.md` + `prd.md` + `checklists/testing.md` | 覆盖缺口（每个 REQ ≥1 自动化测试）；**EXPECTED-TRACE 诚实性（防 AI 自证：标注的锚点真实存在于 prd.md 且值一致）**；边界/错误 case；REQ↔测试可追溯；CLI 优先 / seam 下沉；无快照当预言 |
| `code` | **code-reviewer** | diff + `prd.md` + `requirements.md` + `.aiassist/global/adr/` + `STANDARDS.md` | 正确性、可读性、架构、diff 范围（是否误改测试文件）、对齐契约、范围外实现、Fowler 异味基线 |
| (安全) | security-auditor | diff + `checklists/security.md` + `prd.md` §10.7 | **条件派发**：PRD §10.7 涉及信任边界，或 diff 触及安全敏感 |
| (性能) | performance-auditor | diff + `checklists/performance.md` + `prd.md` §10.7 | **条件派发**：涉及性能敏感路径 |

> 安全/性能为条件派发：仅当 cover 含 `code` 且 PRD §10.7 涉及信任边界/性能敏感路径，或 diff 命中相关区域时派发，避免默认开销。

### 子代理约束

- 每个子代理只负责本层/本维度，不跨维度重复审查。
- 返回结构必须包含：severity（CRITICAL/IMPORTANT/SUGGESTION）、file:line（如有）、问题描述、建议修复、是否阻塞。
- 如果某发现涉及其他 specialist 维度，标注"建议由 X 进一步确认"，而不是自己下结论。

### 代码异味基线（Fowler smell baseline）

`code` 层由 code-reviewer 在其"标准符合"维度应用，其余 specialist 不做重复审查。在 `STANDARDS.md` / `checklists/` 之上，始终携带一组固定的 Fowler 代码异味基线（《Refactoring》ch.3），即使项目没写任何标准也适用。两条绑定规则：

- **仓库标准优先**：项目文档化的标准永远优先；若基线会误报被标准认可的做法，抑制该异味。
- **永远只是判断**：每个异味是带标签的启发式（"疑似 Feature Envy"），不是硬性违规；工具已强制的项直接跳过。

对照 diff 匹配，读作 *是什么 → 怎么修*：

| 异味 | 是什么 | 怎么修 |
|---|---|---|
| **Mysterious Name** | 函数/变量/类型名不揭示其作用或含义 | 重命名；取不出诚实名字说明设计本身浑浊 |
| **Duplicated Code** | 同一逻辑形状在 diff 的多处出现 | 提取共享形状，两处调用 |
| **Feature Envy** | 方法伸手够别的对象的数据，超过自己的 | 把方法移到它羡慕的数据所在处 |
| **Data Clumps** | 同一组字段/参数反复结伴出现（要诞生的类型） | 打包成独立类型，整体传递 |
| **Primitive Obsession** | 基础类型/字符串顶替了应独立成型的领域概念 | 给概念建独立小类型 |
| **Repeated Switches** | 对同一类型的 switch/if 级联在变更里反复出现 | 用多态，或一个双方共享的 map 替代 |
| **Shotgun Surgery** | 一次逻辑改动被逼着散落改多个文件 | 把一起变的收进一个模块 |
| **Divergent Change** | 一个文件/模块为多种无关原因被改动 | 拆分，让每个模块只为一个原因变 |
| **Speculative Generality** | 为规范没有的需求加的抽象/参数/钩子 | 删掉，内联回来，直到真有需要 |
| **Message Chains** | 过长的 `a.b().c().d()` 导航链，调用方不该依赖 | 用首对象上的一个方法藏起这段行走 |
| **Middle Man** | 类/函数大部分只是转发给下游 | 砍掉，直接调真实目标 |
| **Refused Bequest** | 子类/实现者忽略或推翻大部分继承的东西 | 放弃继承，改用组合 |

## 输入

按 cover 层读取对应输入（见 cover → Specialist 子代理表）。**不要依赖当前会话上下文**，所有相关文件都必须显式读取。

## 输出

- `.aiassist/stories/<id>/review.md`（替换 `review-<stage>.md`；git 历史保留旧版）

## 执行步骤

### 1. 解析参数

- `--cover`：可选，逗号分隔 `prd`/`tech`/`req`/`test`/`code`。缺省 = 自动：检查哪些层的输入文件存在，审所有存在的层（末端统一审查时五层全在）。
- `--mode`：可选，`panel`（默认）/ `single`。
- `--story`：可选，缺省取 `.aiassist/stories/` 下最近更新的目录。

### 2. 读取全部输入文件

显式读取 cover 各层所需输入（见 cover → Specialist 子代理表）。

### 3. 按 mode 执行审查

#### Panel 模式（默认）

1. 按 cover 解析要派发的 specialist 列表（安全/性能按条件追加）。
2. 并行派发所有 specialist 子代理（父代理同时等待）。
3. 每个子代理返回本层发现列表。
4. 汇总到 `review.md`：
   - 保留每个 specialist 的分层发现。
   - 总体结论：全部 PASS → PASS；任意 IMPORTANT → WARN；任意 CRITICAL → FAIL。

#### Single 模式

不派子代理，在当前会话中按 cover 各层的审查维度逐项过一遍（沿用 cover → Specialist 子代理表的各层检查点），输出到 `review.md`。

### 4. 生成 review 报告

使用 `templates/story/review-report.md.template`，输出到 `.aiassist/stories/<id>/review.md`。

每个审查项标记为：

- **PASS**：没问题
- **WARN**：有改进空间，但不阻塞
- **FAIL**：阻塞项，建议修复或回流

### 5. 给出结论和建议

向用户汇报：
- 哪些层通过
- 哪些层有警告
- 哪些层失败
- 建议动作：继续 / 修复后重审 / 回流到某层（PRD / TECH-DESIGN / REQ / TEST / BUILD）

### 6. 不自动修改任何产物

`/review` 只输出报告，不改 PRD（含技术方案）、代码或测试。修改由人在后续会话中完成。

## 纪律

- **审查者不实现**：review skill 不写代码、不改测试、不改 PRD。
- **新视角优先**：如果可能，在新会话中调用，减少上下文污染。
- **失败项必须显性处理**：人不能对 FAIL 项视而不见，必须选择修或接受。
- **建议回流但不强制**：review 报告可以建议回流，最终回流决策由人做。
- **ADR 是硬约束**：任何层都必须检查与已有 ADR 是否冲突。
- **CodeGraph 是辅助**：code 层启用 CodeGraph 时，用影响面分析补充人工审查，但不替代代码语义判断。

## 与参考项目的差异

- gstack `review`：给我们代码/PR 审查维度。
- gstack `plan-eng-review`：给我们工程计划审查的问题清单。
- mattpocock `review`：给我们轻量 review 模式。
- 核心差异：把 review 设计成**手动触发、无 stage、cover 自适应、panel 并行 + 汇总**的建议性门，末端统一审全链，融入 test-as-contract 流程。

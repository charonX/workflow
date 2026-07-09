---
name: review
description: 外层设计循环中的手动检查点。在 PRD 后、技术方案后或 BUILD 后，以新会话视角审查产物质量，输出 review 报告；不自动修改产物。
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

人在 PRD、技术方案或代码实现完成后，觉得"需要一双新眼睛看看"时，手动触发：

```
/review --stage=prd --story=<story-id>
/review --stage=tech --story=<story-id>
/review --stage=code --story=<story-id>
```

对于关键/高风险的代码变更，可使用 specialist 子代理并行审查：

```
/review --stage=code --mode=panel --story=<story-id>
```

**建议在新 Claude Code 会话中调用**，避免当前会话的上下文偏见影响审查效果。

如果没有指定 `--story`，默认使用当前工作目录下 `.aiassist/stories/` 中最近更新的 story。

## 两种模式

### 默认模式：单会话审查

- 适用：常规变更、范围小、风险低。
- 在当前会话中读取所有输入文件，按现有维度逐项审查。
- 输出 `review-<stage>.md`。

### Panel 模式：`--mode=panel`（仅 `--stage=code`）

- 适用：关键变更、涉及安全/性能/测试覆盖、需要多视角审查。
- 父代理并行派发 4 个 specialist 子代理，每个负责一个审查维度。
- 汇总到 `review-code.md`，保持与默认模式相同的输出格式。
- Token 成本高于默认模式，明确建议"关键变更再用"。

## 设计原则

- **手动触发**：不是每个 story 的必经环节，由人判断是否需要。
- **新会话友好**：skill 自己读取所有需要文件，不依赖调用会话的上下文。
- **建议性而非强制性**：输出审查报告，人不一定要修复所有问题，但必须显性决策。
- **回流到人决定**：报告可以建议回流，但执行回流由人通过 `/story` 完成。

## Panel 模式： Specialist 子代理

当用户调用 `/review --stage=code --mode=panel` 时，父代理并行派发以下 4 个 specialist 子代理。默认模式（无 `--mode=panel`）不使用子代理。

### Specialist 职责

| 子代理 | 输入 | 审查维度 | 输出 |
|---|---|---|---|
| **code-reviewer** | diff + `prd.md` + `tech-design.md` + `requirements.md` | 正确性、可读性、架构、diff 范围、ADR 对齐、标准符合 | CRITICAL/IMPORTANT/SUGGESTION 列表 |
| **security-auditor** | diff + `checklists/security.md` + `tech-design.md` | 输入验证、鉴权/授权、secrets、依赖 CVE、OWASP Top 10、LLM 安全 | CRITICAL/IMPORTANT/SUGGESTION 列表 |
| **performance-auditor** | diff + `tech-design.md` + `checklists/performance.md` | N+1 查询、无界操作、bundle 大小、渲染模式、缓存、长任务 | CRITICAL/IMPORTANT/SUGGESTION 列表 |
| **test-engineer** | diff + 测试文件 + `requirements.md` + `checklists/testing.md` | 覆盖缺口、测试质量、边界 case、REQ-测试可追溯性 | CRITICAL/IMPORTANT/SUGGESTION 列表 |

### 协调流程

```
/review --stage=code --mode=panel
    │
    ├── 父代理读取 diff、requirements、tech-design、checklists
    │
    ├── 并行派发 4 个子代理
    │   ├── code-reviewer
    │   ├── security-auditor
    │   ├── performance-auditor
    │   └── test-engineer
    │
    ├── 等待所有子代理返回
    │
    └── 父代理合并到 review-code.md
        - 保留原有 "审查项" 表格
        - 新增 "Panel Review" 小节，列出每个 specialist 的发现
        - 总体结论：全部 PASS → PASS；任意 IMPORTANT → WARN；任意 CRITICAL → FAIL
```

### 子代理约束

- 每个子代理只负责本维度，不跨维度重复审查。
- 返回结构必须包含：severity（CRITICAL/IMPORTANT/SUGGESTION）、file:line（如有）、问题描述、建议修复、是否阻塞。
- 如果某发现涉及其他 specialist 维度，标注 "建议由 X-reviewer 进一步确认"，而不是自己下结论。

## 输入

根据 stage 不同：

### stage=prd

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/workflow-state.yaml`

### stage=tech

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/tech-design.md`
- `.aiassist/global/adr/`（检查 ADR 冲突与覆盖）
- `.aiassist/global/adr/README.md`
- `.aiassist/global/architecture.md`（如有，仅作概览）
- `.aiassist/global/CONTEXT.md`（统一术语）
- `.aiassist/global/STANDARDS.md`（如有）

### stage=code

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/tech-design.md`
- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/signoff.md`
- 当前 branch 与 base branch 的 diff
- `.aiassist/global/adr/`（检查实现是否与已有 ADR 冲突）
- `.aiassist/global/CONTEXT.md`（检查术语一致性）
- `.aiassist/global/STANDARDS.md`（如有）
- `.aiassist/global/codegraph.json`（如启用，可做影响面分析）

## 输出

- `.aiassist/stories/<id>/review-<stage>.md`

## 执行步骤

### 1. 解析参数

- `--stage`：必填，`prd` / `tech` / `code`
- `--story`：可选，story-id

如果没有 `--story`，检测当前项目 `.aiassist/stories/` 下最近更新的目录作为默认 story。

### 2. 读取全部输入文件

**不要依赖当前会话上下文。** 所有相关文件都必须显式读取，包括 PRD、tech-design、requirements、全局标准、git diff 等。

### 3. 按 stage 执行审查

#### stage=prd：审查 PRD

| 维度 | 检查点 |
|---|---|
| 痛点锚定 | 问题陈述是否写用户痛点，而非方案？ |
| 稳定块 | 每个稳定块是否清晰到能写出验收标准？ |
| 移动块 | 还在动的块是否明确标注？ |
| 可测试性 | 每个稳定块是否能想象出至少一种验证方式？ |
| 范围 | 范围内/范围外是否明确？ |
| 用户故事 | 是否覆盖主路径和关键边界？ |

#### stage=tech：审查技术方案

| 维度 | 检查点 |
|---|---|
| 对齐 PRD | tech-design 的模块/数据流是否覆盖所有 PRD 稳定块？ |
| 模块边界 | 每个模块职责是否单一？ |
| 接口契约 | 跨模块调用是否有输入/输出/错误/副作用四要素？ |
| 测试 seams | 每个稳定块是否有清晰 seam？ |
| 复杂度 | 是否过度设计？是否有更简方案？ |
| 风险 | 风险与回流点是否明确？ |
| ADR 覆盖 | 满足 ADR 三条件的决策是否已写入 `adr/`？是否与已有 ADR 冲突？ |
| 术语一致性 | 方案中的术语是否与 `CONTEXT.md` 一致？ |
| 标准 | 是否违反项目架构/标准？ |

#### stage=code：审查实现代码

默认模式审查维度：

| 维度 | 检查点 |
|---|---|
| diff 范围 | 是否只包含预期改动？是否误改测试文件？ |
| 对齐契约 | 实现是否与 requirements.md + tech-design.md 一致？ |
| 代码质量 | 明显反模式：硬编码、空 catch、重复代码、过大函数、深嵌套 |
| 标准符合 | 是否违反 `STANDARDS.md`、项目约定、`checklists/` 中的清单？ |
| 范围外 | 是否顺手实现了 PRD 范围外功能？ |
| 副作用 | 是否引入新的跨模块耦合/全局状态？ |
| ADR 冲突 | 实现是否违反已有 ADR？是否引入了需要新 ADR 的决策？ |
| 影响面 | 如启用 CodeGraph，可查询变更函数/模块的依赖关系，检查是否有未覆盖的影响面 |
| 未处理项 | 是否有未处理 TODO、FIXME、临时代码？ |

**Panel 模式（`--mode=panel`）**：上述维度由 4 个 specialist 子代理并行审查，父代理负责汇总。默认模式不派生子代理。

### 4. 生成 review 报告

使用 `templates/story/review-report.md.template`，输出到 `.aiassist/stories/<id>/review-<stage>.md`。

每个审查项标记为：

- **PASS**：没问题
- **WARN**：有改进空间，但不阻塞
- **FAIL**：阻塞项，建议修复或回流

### 5. 给出结论和建议

向用户汇报：
- 哪些维度通过
- 哪些维度有警告
- 哪些维度失败
- 建议动作：继续 / 修复后重审 / 回流到某阶段

### 6. 不自动修改任何产物

`/review` 只输出报告，不改 PRD、tech-design、代码或测试。修改由人在后续会话中完成。

## 纪律

- **审查者不实现**：review skill 不写代码、不改测试、不改 PRD。
- **新视角优先**：如果可能，在新会话中调用，减少上下文污染。
- **失败项必须显性处理**：人不能对 FAIL 项视而不见，必须选择修或接受。
- **建议回流但不强制**：review 报告可以建议回流，最终回流决策由人做。
- **ADR 是硬约束**：stage=tech 和 stage=code 必须检查实现与已有 ADR 是否冲突。
- **CodeGraph 是辅助**：stage=code 启用 CodeGraph 时，用影响面分析补充人工审查，但不替代代码语义判断。

## 与参考项目的差异

- gstack `review`：给我们代码/PR 审查维度。
- gstack `plan-eng-review`：给我们工程计划审查的问题清单。
- mattpocock `review`：给我们轻量 review 模式。
- 核心差异：把 review 设计成**手动触发、多阶段、新会话友好**的建议性门，融入 test-as-contract 流程。

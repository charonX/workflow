---
name: crystallize
description: 把 PRD 中已稳定的块结晶成带 ID 的 REQ，定义验收标准并链接到测试计划。
sources:
  - reference/mattpocock/skills/engineering/grill-with-docs/SKILL.md
  - reference/gstack/plan-eng-review/SKILL.md
  - reference/superpowers/skills/writing-plans/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# crystallize

## 何时调用

PRD 中已有明确稳定块，用户说"生成需求"、"/crystallize"时。或被 `/story` 总入口调用。

## 输入

- `.aiassist/stories/<id>/prd.md`（含 §10 技术方案、§11 测试决策；不再有独立 `tech-design.md`）
- `.aiassist/stories/<id>/workflow-state.yaml`
- `.aiassist/global/business-capabilities.md`（如有，能力地图）
- `.aiassist/global/CONTEXT.md`（如有，统一术语）
- 项目设计系统（`.aiassist/global/DESIGN.md`、`.aiassist/global/tokens.css`）

## 输出

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/requirements-v1.hash`
- `.aiassist/global/business-capabilities.md`（更新能力地图）

## 执行步骤

1. **读取 prd.md 与全局文档**：提取所有标注为"稳定"的块，以及对应的测试 seams（§11.1）、模块边界、接口契约（§10.2-10.4）。读取 `.aiassist/global/business-capabilities.md`，了解现有能力地图；读取 `.aiassist/global/CONTEXT.md`，统一术语。
2. **PRD 完整性轻确认（对话式）**：对照 `prd.md` 第 14 节自检查表及以下清单快速核对：
   - [ ] 每个稳定块至少有一条 happy path（第 6 节）。
   - [ ] `complex` story 必须列出操作分支与异常（第 6.2 节）。
   - [ ] 涉及用户输入的稳定块有字段级验证规则（第 7 节）。
   - [ ] 每个稳定块有失败场景或显式 N/A（第 8 节）。
   - [ ] 跨模块/外部依赖调用有错误状态定义（第 8 节）。
   - [ ] 复杂度分级与 PRD 内容一致（第 9 节）。
3. **处理缺口（不阻断，强制归类）**：发现缺口时——可从上下文推导的就地补进 `prd.md`；需要用户判断的，**问用户归类（四选一）**：
   - **就地补**：现在补进 PRD。
   - **归入移动块（§5）**：暂不做，可能随迭代稳定后进当前 story。
   - **新建 story**：超出当前 story 范围，转去新 story 实现。
   - **归入范围外（§12）**：明确不再实现。
   归类后继续结晶，**不生成 `prd-gap-report.md`、不阻断**。
4. **技术可行性预演**：对每个稳定块，确认实现路径是否明确、是否有可测试的 seam、是否引入新的基础设施依赖。不清晰则降级回 PRD（`complex` story 调用 `/tech-design` 补全 §10；`simple` story 补全高层 §10 与 §11 seams）。
5. **识别 capability 与 entity**：根据 PRD 稳定块和 §10 技术方案中的模块/数据流，为每个 REQ 标注：
   - `capability`：所属业务能力（如 `query-codegraph`、`sign-contract`）
   - `entity`：涉及的核心业务实体（如 `story`、`requirement`、`test-suite`）
   - 如果某个 capability/entity 在 `business-capabilities.md` 中不存在，本次新增。
6. **为每个稳定块分配 REQ-ID**：
   - 格式：`REQ-<PHASE>-NNN`
   - `<PHASE>` 取自当前 story phase（如 BUILD、DESIGN、TEST 等）
   - 编号从 001 开始递增
7. **定义验收标准**：每个 REQ 必须包含具体、可机器验证的标准，以及边界场景和错误处理。**每条验收标准必须能映射到至少一个自动化测试断言。** 验收标准的 expected 值必须源自 `prd.md` §6.3 预期值锚点 / §7 有效无效例子 / §10.4 契约样例；发现缺锚点时视为缺口——可从上下文推导的就地补进 `prd.md`，需人判断的走升级（见第 13 步）。如果某条标准只能用人眼判断（如颜色搭配、间距比例），把它放入 `REFLECT 人工验收备注`，不作为 REQ 的正式验收标准。
8. **标记模块边界属性**：
   - `scope`：单个模块内（`intra-module`）或跨模块（`cross-module`）
   - `modules`：涉及哪些 module/service/executive
   - `interface_contract`：跨模块 REQ 必须显式定义接口契约（输入/输出/错误码/副作用）
9. **生成测试可追溯性**：为每个 REQ 指定 seam、测试类型、预期测试文件路径。路径按能力/实体组织：`tests/capabilities/<capability>/<entity>/...`。
10. **UX/前端 REQ 强制检查**：对涉及 `ux/<flow>.html` 的 REQ，必须回答以下问题并记录结论：
    - 这个 REQ 是否有至少一个可自动验证的结构/行为？
    - 关键元素是否存在性是否可用组件测试覆盖？
    - 交互状态变化（loading/empty/error/success/disabled/主题切换/语言切换）是否可用组件/浏览器测试覆盖？
    - 导航流程（点击 A → 出现 B、路由跳转）是否可自动化？
    - 前端调用 `/api/*` 的参数/时机是否可测试？
    - 如果答案全是“不能”，唯一允许的理由必须是**纯审美判断**（颜色、间距、动效曲线、字体选择）。此时测试类型才能选 `人工(仅视觉)`。
11. **更新业务能力地图**：把新 capability/entity/REQ-ID/测试文件追加到 `.aiassist/global/business-capabilities.md`，保持能力与测试的映射关系。
12. **计算 requirements 哈希**：将 `requirements.md` 内容哈希写入 `requirements-v1.hash`，用于后续检测测试是否过时。
13. **升级点检查（按需，不默认打断）**：默认自动完成，并更新 `workflow-state.yaml`（`phase: TEST`）。仅以下情况停下询问用户：
    - **范围决策**：缺口归类为"新建 story / 范围外"（人的范围判断；"就地补 / 移动块" AI 自决）。
    - **seam 映射失败**：某个稳定块找不到可测试的 seam，且无法从上下文推导（`complex` story 可调用 `/tech-design` 补 §10）。
    - **capability/entity 歧义**：无法从 `CONTEXT.md` / `business-capabilities.md` 消歧。
    其余（REQ-ID 划分、验收标准、expected 值锚定）默认自动完成；用户可随时中断审阅，或单独调用 `/crystallize` 做逐项确认。由 `/story` 自动链调用时不在此停下（升级点由 `/signoff` 统一收敛）。

## REQ 分类维度

| 维度 | 取值 | 说明 |
|---|---|---|
| 优先级 | P0 / P1 / P2 | P0 阻塞发布，P1 重要，P2 优化 |
| 必须性 | 必须 / 应该 / 可以 | 对应 MoSCoW |
| scope | intra-module / cross-module | 是否跨模块 |
| 测试类型 | 单元 / 集成 / E2E / 浏览器 / 组件 / 人工(仅视觉) | 主要验证手段 |
| capability | `business-capabilities.md` 中的能力名 | 所属业务能力 |
| entity | `CONTEXT.md` 中的实体名 | 涉及核心业务实体 |
| UX 参照 | `ux/<flow>.html` | 如有 |

## 纪律

- **没有稳定块就不结晶**：移动块必须留在 PRD，不能进入 REQ。
- **每个 REQ 必须可测试**：验收标准要具体到能写出断言。
- **每个 REQ 必须至少有一个自动化验收标准**：不能整段 REQ 只依赖 REFLECT 人工验收。纯审美判断才允许标为 `人工(仅视觉)`。
- **“人工(仅视觉)”只能用于无法结构化的纯审美判断**：如颜色搭配、间距比例、动效曲线、字体选择。涉及元素存在、状态变化、路由跳转、API 调用的 REQ，必须选择自动化测试类型。
- **跨模块 REQ 必须显式接口契约**：模块之间的契约是二挡最重要的防线。
- **主观判断不进 REQ**：观感/美学问题通过 `/bug` 登记为 `code-defect` 处理，或在 REFLECT 中做最终人工验收；但结构/行为必须已进入 REQ 并有自动化测试。
- **REQ 变更必须重算哈希**：任何修改触发 `requirements-v{N}.hash` 更新，下游测试触发自动重签（高风险项升级给人）。
- **每个 REQ 必须标注 capability/entity**：这是从 story 视图升级到能力视图的基础。
- **不能破坏已有能力地图**：新增 capability/entity 前先检查 `business-capabilities.md`，避免重复命名或冲突。
- **PRD 缺口必须归类，不许悬空**：就地补 / 归入移动块（§5）/ 新建 story / 归入范围外（§12），四选一；不生成阻断文档。

## 与参考项目的差异

- mattpocock `grill-with-docs`：给我们对抗式文档审查方法。
- gstack `plan-eng-review`：给我们架构/边界检查点。
- superpowers `writing-plans`：给我们结构化输出格式。
- 核心差异：REQ-ID 驱动、模块边界显式化、哈希版本控制、capability/entity 可追溯。

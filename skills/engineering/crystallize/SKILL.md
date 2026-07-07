---
name: crystallize
description: 把 PRD 中已稳定的块结晶成带 ID 的 REQ，定义验收标准并链接到测试计划。
disable-model-invocation: true
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

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/tech-design.md`
- `.aiassist/stories/<id>/workflow-state.yaml`
- 项目设计系统（`.aiassist/global/DESIGN.md`、`.aiassist/global/tokens.css`）

## 输出

- `.aiassist/stories/<id>/requirements.md`
- `.aiassist/stories/<id>/requirements-v1.hash`

## 执行步骤

1. **读取 PRD 与 tech-design.md**：提取所有标注为"稳定"的块，以及对应的测试 seams、模块边界、接口契约。
2. **技术可行性预演**：对每个稳定块，确认实现路径是否明确、是否有可测试的 seam、是否引入新的基础设施依赖。不清晰则降级回 PRD/TECH-DESIGN。
3. **为每个稳定块分配 REQ-ID**：
   - 格式：`REQ-<PHASE>-NNN`
   - `<PHASE>` 取自当前 story phase（如 BUILD、DESIGN、TEST 等）
   - 编号从 001 开始递增
3. **定义验收标准**：每个 REQ 必须包含具体、可机器验证的标准，以及边界场景和错误处理。
4. **标记模块边界属性**：
   - `scope`：单个模块内（`intra-module`）或跨模块（`cross-module`）
   - `modules`：涉及哪些 module/service/executive
   - `interface_contract`：跨模块 REQ 必须显式定义接口契约（输入/输出/错误码/副作用）
5. **生成测试可追溯性**：为每个 REQ 指定 seam、测试类型、预期测试文件。
6. **计算 requirements 哈希**：将 `requirements.md` 内容哈希写入 `requirements-v1.hash`，用于后续检测测试是否过时。
7. **提交给用户审查**：请用户确认 REQ-ID 和验收标准。

## REQ 分类维度

| 维度 | 取值 | 说明 |
|---|---|---|
| 优先级 | P0 / P1 / P2 | P0 阻塞发布，P1 重要，P2 优化 |
| 必须性 | 必须 / 应该 / 可以 | 对应 MoSCoW |
| scope | intra-module / cross-module | 是否跨模块 |
| 测试类型 | 单元 / 集成 / E2E / 人工 | 主要验证手段 |
| UX 参照 | `ux/<flow>.html` | 如有 |

## 纪律

- **没有稳定块就不结晶**：移动块必须留在 PRD，不能进入 REQ。
- **每个 REQ 必须可测试**：验收标准要具体到能写出断言。
- **跨模块 REQ 必须显式接口契约**：模块之间的契约是二挡最重要的防线。
- **主观判断不进 REQ**：观感/美学在 `/signoff --stage=feel` 环节依据 HTML 参照验收。
- **REQ 变更必须重算哈希**：任何修改触发 `requirements-v{N}.hash` 更新，下游测试需要重新签核。

## 与参考项目的差异

- mattpocock `grill-with-docs`：给我们对抗式文档审查方法。
- gstack `plan-eng-review`：给我们架构/边界检查点。
- superpowers `writing-plans`：给我们结构化输出格式。
- 核心差异：REQ-ID 驱动、模块边界显式化、哈希版本控制。

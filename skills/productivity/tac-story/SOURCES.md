# 参考来源

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| test-as-contract 设计 | `workflow/design/test-as-contract-workflow.md` | 10 阶段流程、双 Gate 机制、角色分离 |

## 改动记录

- 2026-07-03：增加 `TECH-DESIGN` 阶段路由；归档范围增加 `tech-design.md`；阶段列表同步更新。
- 2026-07-02：重命名为 `/tac-story`(原 `/test-as-contract`),补全路由逻辑与回流机制
  - story = 初衷;实现路径错 → 归档重做;初衷错 → 删 story
  - 根因诊断优先;UX 不归档;按块回流不建 attempt
  - 新增 `workflow-state.yaml` 状态机(phase/attempt/history/archive)
- 2026-07-01：更新阶段引导表
  - DESIGN 阶段新增 `/tac-design-import`(可选) 引导
  - REVIEW 阶段新增 `/tac-design-handoff`(可选) 引导
- 2026-06-25：基于设计文档（`workflow/design/`）实现
  - 10 阶段流程映射
  - 双 Gate（assertion-signoff + feel-signoff）
  - 角色分离（human / test-author / implementer）
  - 阶段可跳过逻辑（无 UI 跳 DESIGN，明确需求跳 THINK）

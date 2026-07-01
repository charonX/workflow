# SOURCES

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| test-as-contract 设计 | `workflow/design/test-as-contract-workflow.md` | 10 阶段流程、双 Gate 机制、角色分离 |

## 改动记录

- 2026-07-01：更新阶段引导表
  - DESIGN 阶段新增 `/design-import`(可选) 引导
  - REVIEW 阶段新增 `/design-handoff`(可选) 引导
- 2026-06-25：基于设计文档（`workflow/design/`）实现
  - 10 阶段流程映射
  - 双 Gate（assertion-signoff + feel-signoff）
  - 角色分离（human / test-author / implementer）
  - 阶段可跳过逻辑（无 UI 跳 DESIGN，明确需求跳 THINK）

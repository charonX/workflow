# SOURCES

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| gstack design-shotgun | `reference/gstack/design-shotgun/SKILL.md` | 多方案变体对比、结构化反馈收集 |
| gstack design-consultation | `reference/gstack/design-consultation/SKILL.md` | 设计系统建设流程、访谈用户 |
| gstack plan-design-review | `reference/gstack/plan-design-review/SKILL.md` | 设计审查维度 |
| baoyu-design system-prompt | `reference/baoyu-design/skills/baoyu-design/system-prompt.md` | HTML 原型方法论、React+Babel 多文件架构、CSS token 约束 |
| baoyu-design hi-fi-design | `reference/baoyu-design/skills/baoyu-design/built-in-skills/hi-fi-design.md` | 设计上下文收集、多方案变体、placeholder 策略 |
| baoyu-design interactive-prototype | `reference/baoyu-design/skills/baoyu-design/built-in-skills/interactive-prototype.md` | React 交互原型、状态管理、表单验证 |
| baoyu-design frontend-design | `reference/baoyu-design/skills/baoyu-design/built-in-skills/frontend-design.md` | 前端审美指引、避免 AI slop |
| baoyu-design wireframe | `reference/baoyu-design/skills/baoyu-design/built-in-skills/wireframe.md` | 线框图策略 |
| test-as-contract 流程 | `workflow/design/test-as-contract-workflow.md` | 双轨收割、PRD 回流机制 |

## 改动记录

- 2026-07-01：吸收 baoyu-design 设计引擎
  - 新增 React + Babel 多文件交互原型规范
  - 新增 Starter Components 目录（设备框架、设计画布、动画引擎等）
  - 新增前端审美指引（调性方向、避免 AI slop）
  - 新增多源设计上下文收集（Figma .fig、GitHub、HTML/CSS）
  - 新增 tokens.css 绑定视觉约束
  - 更新 sources 字段记录 baoyu-design 参考来源
- 2026-06-25：基于设计文档（`workflow/design/`）重新实现
  - 明确"双轨收割"：行为进 PRD/REQ，观感进 HTML
  - 新增 PRD 回流机制
  - 明确不默认使用线框图
  - 新增 `sources` 字段记录参考来源

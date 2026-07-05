# 参考来源

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| gstack design-shotgun | `reference/gstack/design-shotgun/SKILL.md` | 多方案变体对比、结构化反馈收集 |
| gstack design-consultation | `reference/gstack/design-consultation/SKILL.md` | 设计系统建设流程、访谈用户 |
| gstack plan-design-review | `reference/gstack/plan-design-review/SKILL.md` | 设计审查维度 |
| baoyu-design system-prompt | `reference/baoyu-design/skills/baoyu-design/system-prompt.md` | HTML 原型方法论、React+Babel 多文件架构、CSS token 约束 |
| baoyu-design hi-fi-design | `reference/baoyu-design/skills/baoyu-design/built-in-skills/hi-fi-design.md` | 设计上下文收集、多方案变体、占位符策略 |
| baoyu-design interactive-prototype | `reference/baoyu-design/skills/baoyu-design/built-in-skills/interactive-prototype.md` | React 交互原型、状态管理、表单验证 |
| baoyu-design frontend-design | `reference/baoyu-design/skills/baoyu-design/built-in-skills/frontend-design.md` | 前端审美指引、避免 AI 俗套 |
| baoyu-design wireframe | `reference/baoyu-design/skills/baoyu-design/built-in-skills/wireframe.md` | 线框图策略 |
| baoyu-design use-design-system | `reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md` | `_ds/` 导入、`_d_meta.json`、资产版本管理 |
| baoyu-design design-system-preview | `reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-preview.md` | 自包含 `preview.html` 生成 |
| baoyu-design compile/check/preview/import/record | `reference/baoyu-design/skills/baoyu-design/agents/{compile,check,build-preview,import,record}-*.mjs` | story 级设计系统管线脚本 |
| test-as-contract 流程 | `workflow/design/test-as-contract-workflow.md` | 双轨收割、PRD 回流机制 |

## 改动记录

- 2026-07-05：升级 UX 原型为可编译管线
  - 强制依赖已编译的全局设计系统（`_ds_manifest.json` + `_ds_prompt.md`）
  - 默认采用 HTML-native 源，React+Babel 退居可选交互方案
  - 引入 story 级 compile/check/preview/record-asset，产出 `preview.html` 与 `_d_meta.json`
  - 导入全局设计系统运行时拷贝到 `ux/_ds/<slug>/`
  - 新增按需变体流程（`ux/variants/<name>/` + inherit-from）
  - 产物路径与模板引用更新为 `templates/story/ux/`
- 2026-07-01：吸收 baoyu-design 设计引擎
  - 新增 React + Babel 多文件交互原型规范
  - 新增起始组件目录（设备框架、设计画布、动画引擎等）
  - 新增前端审美指引（调性方向、避免 AI 俗套）
  - 新增多源设计上下文收集（Figma .fig、GitHub、HTML/CSS）
  - 新增 tokens.css 绑定视觉约束
  - 更新 sources 字段记录 baoyu-design 参考来源
- 2026-07-03：增加模块/服务边界检查点，在生成 HTML 前识别 UI 流程可能引入的跨模块耦合，并回流 PRD。
- 2026-06-25：基于设计文档（`workflow/design/`）重新实现
  - 明确"双轨收割"：行为进 PRD/REQ，观感进 HTML
  - 新增 PRD 回流机制
  - 明确不默认使用线框图
  - 新增 `sources` 字段记录参考来源

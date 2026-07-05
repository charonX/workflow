# 参考来源

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| baoyu-design handoff-to-claude-code | `reference/baoyu-design/skills/baoyu-design/built-in-skills/handoff-to-claude-code.md` | 开发交接包结构、README 模板、像素级规格描述方式 |
| baoyu-design use-design-system | `reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md` | `_ds/` 导入、`_d_meta.json`、设计系统绑定提示 |
| baoyu-design compile/preview | `reference/baoyu-design/skills/baoyu-design/agents/{compile,build-preview}-*.mjs` | 设计系统清单与预览产物结构 |

## 改动记录

- 2026-07-05：增强交接包为"人类可读 + 机器可读"
  - 新增 `_handoff_manifest.json`，包含 storyId、设计系统绑定、已批准资产、组件 prop 契约、token 白名单、屏幕规格、adherence 配置路径
  - 输入新增 `ux/_d_meta.json`、`ux/_ds_manifest.json`、全局 `_ds_manifest.json`、`_ds_prompt.md`
  - 复制设计文件时一并复制 `_d_meta.json`、`_ds_manifest.json`、`_ds/<slug>/`
  - README 新增"机器可读清单"与"设计系统绑定"章节
- 2026-07-01：新建
  - 基于 baoyu-design 的 handoff-to-claude-code 模式
  - 适配 test-as-contract 流程（放在 `/tac-signoff --stage=feel` 之后）
  - README 模板：screen/view + 组件清单表 + 交互行为 + 状态管理 + token 表 + 素材清单

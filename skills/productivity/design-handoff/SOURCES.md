# 参考来源

## 理念

已批准的 UX 原型必须被"冻结"成机器可读的交接包，让实现阶段不依赖口耳相传。本 skill 是设计与实现之间的格式转换器：人类可读说明书 + 机器可读 manifest，确保观感契约跨会话传递。

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| baoyu-design handoff-to-claude-code | `reference/baoyu-design/skills/baoyu-design/built-in-skills/handoff-to-claude-code.md` | 开发交接包结构、README 模板、像素级规格描述方式 |
| baoyu-design use-design-system | `reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md` | `_ds/` 导入、`_d_meta.json`、设计系统绑定提示 |
| baoyu-design compile | `reference/baoyu-design/skills/baoyu-design/agents/compile-design-system.mjs` | 设计系统清单产物结构 |
| baoyu-design preview | `reference/baoyu-design/skills/baoyu-design/agents/build-preview.mjs` | 自包含预览页生成 |

## 改动记录

- 2026-07-05：增强交接包为"人类可读 + 机器可读"
  - 新增 `_handoff_manifest.json`，包含 storyId、设计系统绑定、已批准资产、组件 prop 契约、token 白名单、屏幕规格、adherence 配置路径
  - 输入新增 `ux/_d_meta.json`、`ux/_ds_manifest.json`、全局 `_ds_manifest.json`、`_ds_prompt.md`
  - 复制设计文件时一并复制 `_d_meta.json`、`_ds_manifest.json`、`_ds/<slug>/`
  - README 新增"机器可读清单"与"设计系统绑定"章节
- 2026-07-01：新建
  - 基于 baoyu-design 的 handoff-to-claude-code 模式
  - 适配 test-as-contract 流程（放在 `/signoff --stage=feel` 之后）
  - README 模板：screen/view + 组件清单表 + 交互行为 + 状态管理 + token 表 + 素材清单

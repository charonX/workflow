# 参考来源：design

## 理念

设计是思考工具，不是最终实现；主观观感留在 HTML 里由人判，行为/结构决策写回 PRD/REQ。本 skill 把建系统、导参考、迭代原型三个设计模式统一为一个入口，减少阶段内的选择负担，同时保留各自的完整流程。

## 借鉴的 reference 文件

本 skill 由以下三个旧 skill 合并而成，保留了它们的参考来源：

| 旧 skill | 参考来源 |
|---|---|
| `design-system` | `reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-authoring-guide.md`、`create-design-system.md`、`use-design-system.md`；`reference/baoyu-design/skills/baoyu-design/agents/compile-design-system.mjs`、`check-design-system.mjs`、`build-preview.mjs`、`import-design-system.mjs`、`record-asset.mjs` |
| `design-import` | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-figma.md`、`import-from-github.md`、`import-from-html.md`、`design-system-authoring-guide.md`、`use-design-system.md` |
| `ux-explore` | `reference/gstack/design-shotgun/SKILL.md`、`design-consultation/SKILL.md`、`plan-design-review/SKILL.md`；`reference/baoyu-design/skills/baoyu-design/system-prompt.md`、built-in-skills 中的 `hi-fi-design.md`、`interactive-prototype.md`、`frontend-design.md`、`wireframe.md`、`use-design-system.md`、`design-system-preview.md` |

## 合并原因

- 减少设计阶段入口，降低认知负担。
- 三个旧 skill 本质上是同一阶段的不同模式：建系统、导参考、迭代原型。
- 统一入口后，`/story` 路由更简单，用户不必在多个设计 skill 之间选择。

## 主要改动

- 创建 `/design` 作为设计阶段唯一入口。
- 内部通过项目状态自动选择模式 A（建/更新设计系统）、B（导入设计来源）、C（迭代 UX 原型）。
- 保留旧 skill 的核心流程、产物路径和纪律。
- 归档旧 skill：`archive/skills/productivity/design-system/`、`design-import/`、`ux-explore/`。

## 改动记录

- 2026-07-06：合并 `tac-design-system`、`tac-design-import`、`tac-ux-explore` 为 `/design`。
- 2026-08-06：PRD 与 tech-design 合并（`design/adr/0004`）：DESIGN 完成后写 `phase=DOMAIN-MODEL`（不再直接写 `TECH-DESIGN`）；复杂 story 之后才进入 `TECH-DESIGN` 深潜。

# SOURCES

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| gstack design-consultation | `reference/gstack/design-consultation/SKILL.md` | 设计系统访谈流程、品牌/字体/色彩/间距系统 |
| mattpocock design-an-interface | `reference/mattpocock/skills/deprecated/design-an-interface/SKILL.md` | 设计系统与代码实现的桥接方式 |
| baoyu-design design-system-authoring | `reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-authoring-guide.md` | 设计系统编译管线、CSS token 作为绑定约束 |
| baoyu-design create-design-system | `reference/baoyu-design/skills/baoyu-design/built-in-skills/create-design-system.md` | 设计系统创建流程 |
| test-as-contract 流程 | `workflow/design/test-as-contract-workflow.md` | design-system → ux-explore 的两步设计流程 |

## 改动记录

- 2026-07-01：吸收 baoyu-design 设计系统模型
  - 新增 `tokens.css` 输出——可运行的 CSS 自定义属性（颜色/字体/间距/圆角/阴影）
  - DESIGN.md 和 tokens.css 双文件输出，tokens.css 作为绑定视觉约束
  - 新增暗色模式 `[data-theme="dark"]` token 支持
  - tokens.css 格式模板和 CSS 变量命名规范（--color-*, --font-*, --space-*, --radius-*, --shadow-*）
  - 移除已失效的 `reference/gstack/design-system/SKILL.md` 引用（上游已删除）
  - 更新 sources 字段记录 baoyu-design 参考来源
- 2026-06-25：基于设计文档（`workflow/design/`）重新实现
  - 明确 design-system 是项目级、一次性的
  - 明确与 ux-explore 的关系
  - 新增 `sources` 字段记录参考来源

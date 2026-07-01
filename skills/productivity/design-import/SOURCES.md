# SOURCES

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| baoyu-design import-from-figma | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-figma.md` | Figma .fig 离线解码流程、mount/materialize/render 三步法 |
| baoyu-design import-from-github | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-github.md` | GitHub 仓库作为设计源的浏览和稀疏导入策略 |
| baoyu-design import-from-html | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-html.md` | HTML/CSS 作为设计参考的 token 提取方法 |

## 改动记录

- 2026-07-01：新建
  - 基于 baoyu-design 的三种设计源导入模式
  - 适配 test-as-contract 流程（产物路径 `.aiassist/design-refs/`）
  - Figma 导入依赖 baoyu-design 的 `import-figma.mjs` 离线解码器
  - GitHub 导入用 `gh api` 浏览 + 稀疏导入
  - HTML/CSS 导入读代码提取 token

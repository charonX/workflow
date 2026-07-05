# 参考来源

这个 skill 参考了以下来源：

| 来源 | 路径 | 借鉴了什么 |
|------|------|-----------|
| baoyu-design import-from-figma | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-figma.md` | Figma .fig 离线解码流程、mount/materialize/render 三步法 |
| baoyu-design import-from-github | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-github.md` | GitHub 仓库作为设计源的浏览和稀疏导入策略 |
| baoyu-design import-from-html | `reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-html.md` | HTML/CSS 作为设计参考的 token 提取方法 |
| baoyu-design design-system-authoring | `reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-authoring-guide.md` | 设计系统目录结构与编译器契约 |
| baoyu-design use-design-system | `reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md` | `_ds/` 导入、`_d_meta.json`、设计系统绑定 |
| baoyu-design compile/check/preview/import | `reference/baoyu-design/skills/baoyu-design/agents/{compile,check,build-preview,import}-*.mjs` | 将导入参考编译并引入项目的脚本 |

## 改动记录

- 2026-07-05：升级导入为可编译/可引入
  - 新增导入后可选 compile/check/preview 步骤，产物 `_ds_manifest.json` / `preview.html`
  - 新增可选 `import-design-system.mjs` 引入项目，生成 `./_ds/<slug>/` 与 `./_d_meta.json`
  - 流程 A/B/C 均增加编译/引入项目步骤
  - 输出提示区分"采纳为项目设计系统"（→ `/tac-design-system`）与"仅作参考"（→ `/tac-ux-explore`）
- 2026-07-01：新建
  - 基于 baoyu-design 的三种设计源导入模式
  - 适配 test-as-contract 流程（产物路径 `.aiassist/design-refs/`）
  - Figma 导入依赖 baoyu-design 的 `import-figma.mjs` 离线解码器
  - GitHub 导入用 `gh api` 浏览 + 稀疏导入
  - HTML/CSS 导入读代码提取 token

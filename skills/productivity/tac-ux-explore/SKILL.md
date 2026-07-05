---
name: tac-ux-explore
description: 基于 PRD 和已编译的项目设计系统，迭代高保真 HTML UX 原型。生成 HTML-native 源，运行 story 级 compile/check/preview，记录资产版本，把行为决策写回 PRD/REQ，把视觉决策保留为 HTML 参照。
disable-model-invocation: true
sources:
  - reference/gstack/design-shotgun/SKILL.md
  - reference/gstack/design-consultation/SKILL.md
  - reference/gstack/plan-design-review/SKILL.md
  - reference/baoyu-design/skills/baoyu-design/system-prompt.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/hi-fi-design.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/interactive-prototype.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/frontend-design.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/wireframe.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-preview.md
  - reference/baoyu-design/skills/baoyu-design/agents/compile-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/check-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/build-preview.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/import-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/record-asset.mjs
  - workflow/design/test-as-contract-workflow.md
---

# ux-explore

## 何时调用

PRD 已生成，需要把抽象需求转成可视化的 HTML 原型时。如果 PRD 里某个功能没有 UI（纯后台逻辑），跳过本 skill，直接 `/tac-crystallize`。

## 输入

- `.aiassist/stories/<id>/prd.md`
- `.aiassist/stories/<id>/workflow-state.yaml`
- 已编译的项目设计系统：
  - `.aiassist/global/_ds_manifest.json`
  - `.aiassist/global/_ds/<slug>/_ds_prompt.md`
  - `.aiassist/global/preview.html`
- 可选：竞品截图/参考、Figma .fig 文件、GitHub 仓库链接、已有 HTML/CSS

## 输出

写入 `.aiassist/stories/<id>/ux/`：

- `*.html` — HTML 原型（每张第一行含 `<!-- @dsCard -->`）
- `components/*.jsx` + `*.d.ts` — story 局部组件（可选）
- `tokens.css` — story 局部 token 覆盖（可选）
- `_ds_bundle.js` — 局部组件编译产物（可选）
- `_ds_manifest.json` — story 级清单（可选）
- `preview.html` — story 自包含预览页
- `_d_meta.json` — 资产注册表 + 设计系统绑定
- `_ds/<slug>/` — 全局设计系统运行时拷贝 + `_ds_prompt.md`

对 PRD 的反馈：哪些行为决策需要补进 PRD/REQ。

## 执行步骤

1. **检查设计系统**：
   - 查找 `.aiassist/global/_ds_manifest.json`。缺失则调用 `/tac-design-system` 先完成编译。
   - 读取 `.aiassist/global/_ds_manifest.json`，了解命名空间、可用组件、token 列表。
   - 读取 `.aiassist/global/_ds/<slug>/_ds_prompt.md`，获取组件用法与 token 约束。
2. **收集设计上下文**（多源）：
   - 询问用户是否有截图、Figma .fig 文件、GitHub 仓库或已有 HTML/CSS 作为设计参考。
   - 如果有 Figma .fig 文件，调用 `/tac-design-import` 导入。
   - 如果有 GitHub 仓库作为设计源，用 `gh api` 浏览。
   - 设计上下文是高质量设计的最大杠杆——**要极力争取**。
3. **读取 PRD**，识别需要可视化的用户流程。
4. **检查模块/服务边界**：
   - 这个 UI 流程会调用哪些 module/service/executive？
   - 是否会因为 UI 决策而引入新的跨模块耦合？
   - 把发现的边界问题反馈回 PRD 第 6.1 节，必要时回流 `/tac-to-prd`。
5. **明确方向和变体**：
   - 确认范围：哪些屏幕/流程需要设计。
   - 确认变体数量：要几个方案？探索什么维度（视觉风格/交互方式/布局/主题）？
   - 确认是偏"遵循现有模式"还是偏"新颖大胆"。
   - 如果没有品牌系统约束，遵循**前端审美指引**（见下文）。
6. **导入全局设计系统到 story**：
   ```bash
   node scripts/design-system/import-design-system.mjs .aiassist/global .aiassist/stories/<id>/ux --primary
   ```
   这会在 `ux/_ds/<slug>/` 生成运行时拷贝，并初始化/更新 `ux/_d_meta.json`。
7. **生成第一版 HTML 原型**：
   - **默认使用 HTML-native 源**：plain HTML/CSS/JS 直接写页面，引用 `ux/_ds/<slug>/styles.css`。
   - 需要复杂交互时，才使用 React + Babel Standalone；组件优先从设计系统 bundle 取：`const { Button } = window.<Namespace>;`。
   - story 局部 JSX 组件放在 `ux/components/*.jsx` + `*.d.ts`。
   - 每个 `.html` 文件第一行必须是 `<!-- @dsCard group="..." name="..." viewport="..." -->`。
   - 在 HTML 头部添加注释：关联的 REQ-ID、版本、日期。
   - 参考模板：`templates/story/ux/flow.html.template`。
8. **运行 story 级编译管线**：
   ```bash
   node scripts/design-system/compile-design-system.mjs .aiassist/stories/<id>/ux
   node scripts/design-system/check-design-system.mjs .aiassist/stories/<id>/ux
   node scripts/design-system/build-preview.mjs .aiassist/stories/<id>/ux --out .aiassist/stories/<id>/ux/preview.html
   ```
   如果 story 没有局部 JSX 组件，compile 只会生成轻量 manifest；不会报错。
9. **记录资产**：
   ```bash
   node scripts/design-system/record-asset.mjs .aiassist/stories/<id>/ux <flow>.html --name "<Flow Name>" --status needs-review
   ```
   对多个 flow 重复执行。
10. **呈现给用户**：
    - 通过 localhost 预览：`python3 -m http.server 4311 --directory .aiassist/stories/<id>/ux`
    - 让用户打开 `preview.html` 或具体 `flow.html`。
    - "这是第一版高保真 HTML，哪里不对？"
11. **迭代**：根据用户反馈修改 HTML，直到用户说"这就是我想要的感觉"。
    - 如需多个方案对比，使用 design-canvas 组件并排展示。
    - 如需微调，可构建页内微调面板（颜色/字体/间距滑块）。
    - 每次修改后重新跑步骤 8-9，确保 `preview.html` 与 `_d_meta.json` 最新。
12. **变体生成**（按需）：
    - 在 `ux/variants/<name>/` 下创建目录（如 `dark`、`compact`）。
    - 复制基线 HTML，应用 token 覆盖（`tokens.css`）。
    - 对该目录跑 compile/check/preview。
    - 记录资产并设置 `inherit-from` 指向基线 HTML：
      ```bash
      node scripts/design-system/record-asset.mjs .aiassist/stories/<id>/ux variants/dark/flow-a.html --name "Flow A — Dark" --inherit-from flow-a.html --status needs-review
      ```
    - 在 `workflow-state.yaml` 的 `variants.active` 中追加变体名。
13. **双轨收割**：
    - **行为/结构决策** → 写成文字，更新 PRD 的 `稳定块`，必要时重新 `/tac-crystallize`。
    - **视觉/交互决策** → 保留在 HTML 中，作为 Gate 2 参照。
14. **处理 PRD 回流**（同现有流程）。
15. **更新 workflow-state**：标记 DESIGN 阶段完成，并记录 `design_system.slug`、`assets.recorded`、`variants.active`。

## HTML-native 源纪律

- **源文件优先是 HTML/CSS/JS**：每个 `.html` 是自包含、可直接在浏览器打开的原型。
- React + Babel 仅用于复杂状态/交互；简单展示、静态页面不用 React。
- 样式优先使用设计系统 token 和普通 CSS class；避免 CSS-in-JS。
- story 局部组件必须配 `.d.ts` 类型契约，才能被 `_ds_manifest.json` 记录和下游 implementer 读取。

## 引用设计系统组件

在 HTML 中加载 bundle 后使用：

```html
<link rel="stylesheet" href="_ds/{{SLUG}}/styles.css">
<script src="_ds/{{SLUG}}/_ds_bundle.js"></script>
<script type="text/babel">
  const { Button } = window.{{NAMESPACE}};
  // ...
</script>
```

命名空间从 `.aiassist/global/_ds_manifest.json` 的 `namespace` 字段读取。

## React 原型规范（可选）

多文件原型使用 React 18.3.1 + Babel Standalone，通过 HTTP 加载 `.jsx` 文件：

```html
<script src="https://unpkg.com/react@18.3.1/umd/react.development.js"></script>
<script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js"></script>
<script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js"></script>
<script type="text/babel" src="data.jsx"></script>
<script type="text/babel" src="app.jsx"></script>
```

**关键规则**：
- 每个 `<script type="text/babel">` 有独立作用域，跨文件共享的组件挂到 `window`：`Object.assign(window, { MyComponent });`
- 样式对象用**唯一名称**：`const sidebarStyles = {...}` 而非 `const styles = {...}`
- 优先用 CSS 样式表 + `className`，仅动态值用 inline `style={{}}`
- 共享状态提升到 `App`，通过 props 下传，不分散 `useState` 到不同文件

### 文件拆分指南

| 文件 | 内容 | 职责 |
|------|------|------|
| `data.jsx` | 模拟数据、内容、辅助函数 | 纯数据 |
| `icons.jsx` | SVG 图标组件 | 纯展示 |
| `panes.jsx` | 侧栏、列表、阅读器等展示组件 | props 传入，回调传出 |
| `app.jsx` | App 顶层 + state + 弹窗/选择 | 状态持有者 |

## 起始组件

`starter-components/` 目录提供开箱即用的脚手架，复制到项目后使用：

| 组件 | 文件 | 用途 |
|------|------|------|
| iOS 设备框架 | `ios-frame.jsx` | iPhone 状态栏 + home indicator + 键盘 |
| Android 设备框架 | `android-frame.jsx` | Android 状态栏 + 导航栏 + 键盘 |
| macOS 窗口 | `macos-window.jsx` | macOS 窗口 chrome + 红绿灯 |
| 浏览器窗口 | `browser-window.jsx` | 浏览器 chrome + 标签页 + URL 栏 |
| 设计画布 | `design-canvas.jsx` | 平移/缩放画布，多方案并排对比 |
| 动画引擎 | `animations.jsx` | Timeline 动画（舞台、精灵、缓动） |
| 幻灯片舞台 | `deck-stage.js` | 幻灯片缩放/导航/缩略图 |
| 图片占位槽 | `image-slot.js` | 用户拖放图片的占位区域 |
| 微调面板 | `tweaks-panel.jsx` | 页内颜色/字体/间距控件 |

**使用方式**：`cp starter-components/<file> .aiassist/stories/<id>/ux/` 然后通过 `<script>` 引用。

## 前端审美指引

当设计**不受现有品牌系统约束**时，遵循以下原则：

- **调性**：选一个极端方向——极简/极繁/复古未来/有机自然/奢华/玩趣/编辑风/粗野主义/Art Deco/柔和粉彩/工业实用
- **字体**：选独特有品格的字体，避免 Inter/Roboto/Arial。展示字体 + 正文字体配对
- **颜色**：主导色 + 锐利强调色优于均匀分布。用 CSS 变量保持一致性
- **动效**：聚焦高影响力时刻——一次精心编排的页面加载胜过零散微交互
- **空间**：不对称、重叠、对角线流动、大量留白或受控密度
- **背景**：渐变网格、噪点纹理、几何图案、叠层透明

### 避免 AI 俗套
- 不滥用渐变背景、emoji、圆角卡片+左边框强调色
- 不用 Inter/Roboto/Arial/Fraunces 等过度使用的字体
- 不用 SVG 手绘替代图片——用占位符并请用户提供真实素材
- 不填充无意义的数据/图标/统计数字

## 线框图说明

不默认使用线框图。例外：用户明确要求快速探索布局骨架时，可生成低保真线框图——简单形状、占位文字、最少颜色、手绘感，**不作为 Gate 2 参照**。

## 产物路径

- `.aiassist/stories/<id>/ux/<flow-name>.html`
- `.aiassist/stories/<id>/ux/preview.html`
- `.aiassist/stories/<id>/ux/_d_meta.json`
- `.aiassist/stories/<id>/ux/_ds/<slug>/`

## 纪律

- DESIGN 阶段**不写测试、不写实现代码**。
- HTML 是思考工具，不是最终实现。
- 主观判断（"好看""舒服"）留在 HTML 里，由 Gate 2 人判。
- **新功能必须回流 PRD**，不能直接从 HTML 跳进代码。
- **提前暴露模块耦合**：UI 流程常常暴露模块边界问题，发现后立刻回流 PRD。
- **优先从设计上下文出发**——截图、Figma 文件、代码库优于从零设计。
- **设计系统 token 是绑定的**——不发明系统外颜色或样式；如需新 token，回 `/tac-design-system`。
- **每次 HTML 修改后重新 compile/check/preview/record**，保证 `_d_meta.json` 与 `preview.html` 是最新真实状态。

## 与参考项目的差异

- gstack `design-shotgun`：强调多方案对比；我们用 design-canvas 组件实现并排对比
- baoyu-design：完整设计引擎；我们吸收其 HTML 原型方法论、起始组件、前端审美指引、编译管线
- 核心差异：基于已编译项目设计系统、HTML-native 源、资产版本记录、双轨收割、PRD 回流机制

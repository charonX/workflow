---
name: tac-ux-explore
description: 基于 PRD 和项目设计系统，生成并迭代高保真 HTML UX 原型。把行为决策写回 PRD/REQ，把视觉决策保留为 HTML 参照。
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
  - workflow/design/test-as-contract-workflow.md
---

# ux-explore

## 何时调用

PRD 已生成，需要把抽象需求转成可视化的 HTML 原型时。如果 PRD 里某个功能没有 UI（纯后台逻辑），跳过本 skill，直接 `/tac-crystallize`。

## 输入

- `.aiassist/stories/<id>/prd.md`
- 项目设计系统（`.aiassist/global/DESIGN.md`、`.aiassist/global/tokens.css`）
- 可选：竞品截图/参考、Figma .fig 文件、GitHub 仓库链接、已有 HTML/CSS

## 输出

- `.aiassist/stories/<id>/ux/<flow>.html` 及其 JSX 组件文件
- 对 PRD 的反馈：哪些行为决策需要补进 PRD/REQ

## 执行步骤

1. **检查设计系统**:
   - 查找 `.aiassist/global/DESIGN.md`、`.aiassist/global/tokens.css` 或 `.aiassist/global/STANDARDS.md`。
   - 如果不存在，调用 `/tac-design-system` 先建设设计系统。
   - 如果存在 `.aiassist/global/tokens.css`，在 HTML 原型中通过 `<link rel="stylesheet" href="../../global/tokens.css">` 引用，作为**绑定视觉约束**——不发明系统外颜色或样式。

2. **收集设计上下文**（多源）：
   - 询问用户是否有截图、Figma .fig 文件、GitHub 仓库或已有 HTML/CSS 作为设计参考。
   - 如果有 Figma .fig 文件，调用 `/tac-design-import` 导入。
   - 如果有 GitHub 仓库作为设计源，用 `gh api` 浏览。
   - 设计上下文是高质量设计的最大杠杆——**要极力争取**。

3. **读取 PRD**，识别需要可视化的用户流程。

4. **明确方向和变体**：
   - 确认范围：哪些屏幕/流程需要设计。
   - 确认变体数量：要几个方案？探索什么维度（视觉风格/交互方式/布局）？
   - 确认是偏"遵循现有模式"还是偏"新颖大胆"。
   - 如果没有品牌系统约束，遵循**前端审美指引**（见下文）。

5. **生成第一版 HTML 原型**：
   - 使用项目设计系统的 token（`.aiassist/global/tokens.css` 或 `.aiassist/global/DESIGN.md` 中的颜色/字体/间距）。
   - **交互原型默认使用 React + Babel**：对于需要交互的流程（表单、多步骤、状态切换），使用 React useState/useEffect 构建真实可交互原型。
   - 对于多文件原型，拆分 JSX 组件：`data.jsx`（模拟数据）→ `icons.jsx` → `panes.jsx`（展示组件）→ `app.jsx`（App + state）。
   - 利用 **起始组件**（见下文）加速开发。
   - 在 HTML 头部添加注释：关联的 REQ-ID、版本、日期。

6. **呈现给用户**：
   - 通过 localhost 预览：`python3 -m http.server 4311 --directory .aiassist/stories/<id>/ux`
   - "这是第一版高保真 HTML，哪里不对？"

7. **迭代**：根据用户反馈修改 HTML，直到用户说"这就是我想要的感觉"。
   - 如需多个方案对比，使用 design-canvas 组件并排展示。
   - 如需微调，可构建页内微调面板（颜色/字体/间距滑块）。

8. **双轨收割**：
   - **行为/结构决策** → 写成文字，更新 PRD 的 `稳定块`，必要时重新 `/tac-crystallize`。
   - **视觉/交互决策** → 保留在 HTML 中，作为 Gate 2 参照。

9. **处理 PRD 回流**（同现有流程）。

10. **更新 workflow-state**：标记 DESIGN 阶段完成。

## React 原型规范

多文件原型使用 React 18.3.1 + Babel Standalone，通过 HTTP 加载 `.jsx` 文件：

```html
<script src="https://unpkg.com/react@18.3.1/umd/react.development.js" ...></script>
<script src="https://unpkg.com/react-dom@18.3.1/umd/react-dom.development.js" ...></script>
<script src="https://unpkg.com/@babel/standalone@7.29.0/babel.min.js" ...></script>
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

`.aiassist/stories/<id>/ux/<flow-name>.html`

## 纪律

- DESIGN 阶段**不写测试、不写实现代码**。
- HTML 是思考工具，不是最终实现。
- 主观判断（"好看""舒服"）留在 HTML 里，由 Gate 2 人判。
- **新功能必须回流 PRD**，不能直接从 HTML 跳进代码。
- **优先从设计上下文出发**——截图、Figma 文件、代码库优于从零设计。
- **设计系统 token 是绑定的**——不发明系统外颜色或样式。

## 与参考项目的差异

- gstack `design-shotgun`：强调多方案对比；我们用 design-canvas 组件实现并排对比
- baoyu-design：完整设计引擎；我们吸收其 HTML 原型方法论、起始组件、前端审美指引
- 核心差异：基于项目设计系统、双轨收割、PRD 回流机制、React 交互原型

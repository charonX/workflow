---
name: design-handoff
description: 在 `/signoff --stage=feel` 完成后，将已批准的 UX 原型与绑定设计系统转化为结构化开发交接包——增强版 README + 机器可读 _handoff_manifest.json + 设计文件打包，开发人员可脱离设计对话独立实现。
sources:
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/handoff-to-claude-code.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md
  - reference/baoyu-design/skills/baoyu-design/agents/compile-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/build-preview.mjs
---

# design-handoff

## 何时调用

- `/signoff --stage=feel` 完成，用户对 HTML 原型的视觉和交互感到满意。
- 需要将设计移交给开发人员（或自己的开发阶段）实现。
- 用户明确说"生成开发交接文档"、"/design-handoff"。

## 前置条件

- `/design` 已完成（模式 C），HTML 原型存在于 `.aiassist/stories/<id>/ux/`
- `/signoff --stage=feel` 已完成，用户确认了原型的感觉

## 输入

- `.aiassist/stories/<id>/ux/` 下的 HTML 原型文件
- `.aiassist/stories/<id>/ux/_d_meta.json` — 资产注册表 + 设计系统绑定
- `.aiassist/stories/<id>/ux/_ds_manifest.json` — story 级组件清单（如有局部组件）
- `.aiassist/global/_ds_manifest.json` — 项目级设计系统清单
- `.aiassist/global/_ds/<slug>/_ds_prompt.md` — 设计系统使用提示
- `.aiassist/stories/<id>/prd.md` — 功能需求
- `.aiassist/global/DESIGN.md` 与 `tokens.css` — 设计系统人读文档与 token

## 输出

- `.aiassist/stories/<id>/design_handoff/README.md` — 结构化开发交接文档（人类可读）
- `.aiassist/stories/<id>/design_handoff/_handoff_manifest.json` — 机器可读交接清单
- `.aiassist/stories/<id>/design_handoff/` — 复制了相关设计文件（HTML/JSX/CSS、_d_meta.json、_ds_manifest.json、_ds_prompt.md）

## 执行步骤

1. **创建交接目录**：
   ```bash
   mkdir -p .aiassist/stories/<id>/design_handoff/
   ```

2. **读取元数据**：
   - 读取 `.aiassist/stories/<id>/ux/_d_meta.json`，获取已记录资产列表、状态、版本、设计系统绑定。
   - 读取 `.aiassist/stories/<id>/ux/_ds_manifest.json`（如存在），获取 story 局部组件与 prop 契约。
   - 读取 `.aiassist/global/_ds_manifest.json`，获取全局设计系统的 namespace、组件、token、字体。
   - 读取 `.aiassist/global/_ds/<slug>/_ds_prompt.md`，获取组件用法与 token 约束。

3. **分析原型文件**：
   - 读取 `.aiassist/stories/<id>/ux/` 下所有 HTML/JSX 文件。
   - 识别每个屏幕/视图。
   - 提取每个 UI 组件的：位置、尺寸、颜色、字体、圆角、阴影、状态。
   - 提取交互行为：点击、悬停、动画、表单验证、状态转换。
   - 提取数据流：状态变量、props 传递、事件处理。

4. **生成 `_handoff_manifest.json`**（机器可读）：
   ```json
   {
     "storyId": "<id>",
     "designSystem": {
       "namespace": "...",
       "slug": "...",
       "sourcePath": ".aiassist/global",
       "promptPath": ".aiassist/global/_ds/<slug>/_ds_prompt.md"
     },
     "assets": [
       { "name": "Flow A", "path": "ux/flow-a.html", "status": "approved", "versions": [...] }
     ],
     "components": [
       { "name": "Button", "sourcePath": ".aiassist/global/components/Button.jsx", "props": [...] }
     ],
     "tokens": ["--color-primary", "--spacing-md", ...],
     "screens": [
       { "name": "Flow A", "viewport": {"width": 1280, "height": 800} }
     ],
     "adherenceConfig": ".aiassist/global/_adherence.oxlintrc.json"
   }
   ```

5. **生成 README.md**（结构如下）：

```markdown
# 开发交接：<功能名称>

## 概述
<这个设计是做什么的，解决什么问题>

## 关于设计文件
明确声明：`design_handoff/` 中的 HTML 文件是**设计参照**——展示预期的外观和行为，
不是直接复制的生产代码。开发任务是在目标代码库的现有环境中**重新创建这些设计**，
使用其既有模式、组件库和框架。如果没有现成环境，则为项目选择最合适的框架来实现。

## 机器可读清单
- `_handoff_manifest.json` 包含：storyId、设计系统绑定、已批准资产列表、组件 prop 契约、token 白名单、屏幕规格、adherence lint 配置路径。
- 实现阶段应优先读取 `_handoff_manifest.json` 与 `.aiassist/global/_ds/<slug>/_ds_prompt.md`。

## 保真度
- **高保真**：像素级精确的样稿，含最终颜色、字体、间距和交互。
  开发者应在目标环境中**像素级还原**。
- **低保真**：线框图/布局骨架，展示结构和流程。
  开发者用这些作为布局和功能指南，用代码库的既有设计系统填充样式。

## 设计系统绑定
- 命名空间：`window.<Namespace>`
- 运行时拷贝路径：`design_handoff/_ds/<slug>/`
- 使用提示文件：`design_handoff/_ds/<slug>/_ds_prompt.md`
- 组件清单与 prop 契约见 `_handoff_manifest.json`

## 屏幕 / 视图

### <屏幕名称 1>
- **目的**：用户在这里做什么
- **布局**：详细的布局描述（grid 结构、flex 方向、宽高、边距、内边距）

#### 组件清单
| 组件 | 位置/尺寸 | 颜色 | 字体 | 圆角/阴影 | 状态 |
|------|----------|------|------|----------|------|
| <Button> | w:120px h:40px | bg:#007aff text:#fff | 14px/500 | radius:8px | hover:#0056cc active:scale(0.97) |
| ... | ... | ... | ... | ... | ... |

（每个屏幕重复此表）

## 交互与行为
- 点击处理和导航流程
- 动画和过渡（时长、缓动、属性）
- 悬停状态
- 加载状态
- 错误状态
- 表单验证规则
- 响应式行为（如适用）

## 状态管理
- 需要的状态变量
- 状态转换及其触发器
- 数据获取需求

## 设计 Token
列出所有使用的设计值：

### 颜色
| Token | 值 | 用途 |
|-------|-------|-------|
| --color-primary | #007aff | 主按钮、链接 |
| ... | ... | ... |

### 字体
| 层级 | 字体 | 字号 | 字重 | 行高 |
|-------|------|------|--------|-------------|
| 标题 | SF Pro Display | 32px | 700 | 1.25 |
| 正文 | SF Pro Text | 16px | 400 | 1.5 |
| ... | ... | ... | ... | ... |

### 间距
| Token | 值 |
|-------|-------|
| --space-4 | 16px |
| ... | ... |

### 圆角
| Token | 值 |
|-------|-------|
| --radius-md | 8px |
| ... | ... |

### 阴影
| Token | 值 |
|-------|-------|
| --shadow-md | 0 4px 6px rgba(0,0,0,0.07) |
| ... | ... |

## 素材
列出设计中使用的图片、图标和其他素材及其来源：

| 素材 | 文件 | 来源 |
|-------|------|--------|
| Logo | assets/logo.svg | 项目品牌素材 |
| 主视觉图 | assets/hero.png | 用户提供 |
| ... | ... | ... |

## 文件
交接包中的设计文件列表：

| 文件 | 说明 |
|------|-------------|
| ux/<flow>.html | 主原型入口 |
| ux/app.jsx | React 应用组件 |
| ux/data.jsx | 模拟数据 |
| _handoff_manifest.json | 机器可读交接清单 |
| _ds/<slug>/_ds_prompt.md | 设计系统使用提示 |
| ... | ... |
```

6. **复制设计文件**：
   ```bash
   cp .aiassist/stories/<id>/ux/*.html .aiassist/stories/<id>/design_handoff/
   cp .aiassist/stories/<id>/ux/*.jsx .aiassist/stories/<id>/design_handoff/
   cp .aiassist/stories/<id>/ux/*.css .aiassist/stories/<id>/design_handoff/
   cp .aiassist/stories/<id>/ux/_d_meta.json .aiassist/stories/<id>/design_handoff/
   cp .aiassist/stories/<id>/ux/_ds_manifest.json .aiassist/stories/<id>/design_handoff/
   cp -R .aiassist/stories/<id>/ux/_ds .aiassist/stories/<id>/design_handoff/
   ```
   只复制源文件与元数据，不复制 `starter-components/` 中的脚手架（它们在交接包中不需要，开发人员用目标框架实现）。

7. **询问用户**：是否需要包含设计截图？（默认不包含，README + manifest 已足够）

8. **总结**：交接包已生成，路径为 `.aiassist/stories/<id>/design_handoff/README.md`，机器可读清单为 `_handoff_manifest.json`。

## 重要说明

- 对尺寸、颜色、字体的描述要**极其精确**——开发人员依赖此文档实现。
- README 必须一开始就声明：HTML 文件是**设计参照**，任务是在目标应用中重新创建设计。
- README 应该**自给自足**——一个没参与设计对话的开发人员应该能从 README 独立实现。
- 如果设计使用了项目设计系统的 token，引用 `.aiassist/global/tokens.css` 中的变量名而非硬编码值。
- 不包含未经确认的推测性内容。
- `_handoff_manifest.json` 是下游 `/implementer` 可直接读取的契约输入。

## 产物路径

- `.aiassist/stories/<id>/design_handoff/README.md`
- `.aiassist/stories/<id>/design_handoff/_handoff_manifest.json`

## 纪律

- 交接包是**交付物**，不是迭代工具——只在 `/signoff --stage=feel` 后生成。
- 描述精确到像素——"约 16px"不行，要"16px"。
- 状态覆盖完整——加载、空态、错误、边界情况。
- 不添加设计中不存在的内容。
- `_handoff_manifest.json` 必须与 HTML 原型、`_d_meta.json`、全局设计系统清单保持一致。

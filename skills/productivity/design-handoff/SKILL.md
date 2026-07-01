---
name: design-handoff
description: 在 `/feel-signoff` 完成后，将 UX 原型转化为结构化开发交接包——README（像素级规格 + 交互行为 + 状态管理）+ 设计文件打包，开发人员可脱离设计对话独立实现。
disable-model-invocation: true
sources:
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/handoff-to-claude-code.md
---

# design-handoff

## 何时调用

- `/feel-signoff` 完成，用户对 HTML 原型的视觉和交互感到满意。
- 需要将设计移交给开发人员（或自己的开发阶段）实现。
- 用户明确说"生成开发交接文档"、"/design-handoff"。

## 前置条件

- `/ux-explore` 已完成，HTML 原型存在于 `.aiassist/stories/<id>/ux/`
- `/feel-signoff` 已完成，用户确认了原型的感觉

## 输入

- `.aiassist/stories/<id>/ux/` 下的 HTML 原型文件
- `.aiassist/stories/<id>/prd.md`（了解功能需求）
- 项目 `tokens.css` 或 `DESIGN.md`（了解设计系统）

## 输出

- `.aiassist/stories/<id>/design_handoff/README.md` — 结构化开发交接文档
- `.aiassist/stories/<id>/design_handoff/` — 复制了相关设计文件

## 执行步骤

1. **创建交接目录**：
   ```
   mkdir -p .aiassist/stories/<id>/design_handoff/
   ```

2. **分析原型文件**：
   - 读取 `.aiassist/stories/<id>/ux/` 下所有 HTML/JSX 文件
   - 识别每个屏幕/视图
   - 提取每个 UI 组件的：位置、尺寸、颜色、字体、圆角、阴影、状态
   - 提取交互行为：点击、悬停、动画、表单验证、状态转换
   - 提取数据流：状态变量、props 传递、事件处理

3. **生成 README.md**（结构如下）：

```markdown
# 开发交接：<功能名称>

## 概述
<这个设计是做什么的，解决什么问题>

## 关于设计文件
明确声明：`design_handoff/` 中的 HTML 文件是**设计参照**——展示预期的外观和行为，
不是直接复制的生产代码。开发任务是在目标代码库的现有环境中**重新创建这些设计**，
使用其既有模式、组件库和框架。如果没有现成环境，则为项目选择最合适的框架来实现。

## 保真度
- **高保真**：像素级精确的样稿，含最终颜色、字体、间距和交互。
  开发者应在目标环境中**像素级还原**。
- **低保真**：线框图/布局骨架，展示结构和流程。
  开发者用这些作为布局和功能指南，用代码库的既有设计系统填充样式。

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
| ... | ... |
```

4. **复制设计文件**：
   ```bash
   cp .aiassist/stories/<id>/ux/*.html .aiassist/stories/<id>/design_handoff/
   cp .aiassist/stories/<id>/ux/*.jsx .aiassist/stories/<id>/design_handoff/
   cp .aiassist/stories/<id>/ux/*.css .aiassist/stories/<id>/design_handoff/
   ```
   只复制源文件，不复制 `starter-components/` 中的脚手架（它们在交接包中不需要，开发人员用目标框架实现）。

5. **询问用户**：是否需要包含设计截图？（默认不包含，README 已足够）

6. **总结**：交接包已生成，路径为 `.aiassist/stories/<id>/design_handoff/README.md`。

## 重要说明

- 对尺寸、颜色、字体的描述要**极其精确**——开发人员依赖此文档实现。
- README 必须一开始就声明：HTML 文件是**设计参照**，任务是在目标应用中重新创建设计。
- README 应该**自给自足**——一个没参与设计对话的开发人员应该能从 README 独立实现。
- 如果设计使用了项目设计系统的 token，引用 `tokens.css` 中的变量名而非硬编码值。
- 不包含未经确认的推测性内容。

## 产物路径

`.aiassist/stories/<id>/design_handoff/README.md`

## 纪律

- 交接包是**交付物**，不是迭代工具——只在 `/feel-signoff` 后生成。
- 描述精确到像素——"约 16px"不行，要"16px"。
- 状态覆盖完整——加载、空态、错误、边界情况。
- 不添加设计中不存在的内容。

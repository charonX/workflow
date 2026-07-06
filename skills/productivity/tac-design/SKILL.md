---
name: tac-design
description: 设计阶段统一入口。人在上，AI 在下：设计系统由人驱动、来源优先；story 级 UX 原型在确认范围后生成。
disable-model-invocation: true
sources:
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-authoring-guide.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/create-design-system.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-figma.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-github.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/import-from-html.md
  - reference/baoyu-design/skills/baoyu-design/system-prompt.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/hi-fi-design.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/interactive-prototype.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/frontend-design.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-preview.md
  - reference/baoyu-design/skills/baoyu-design/agents/compile-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/check-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/build-preview.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/import-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/record-asset.mjs
  - reference/gstack/design-shotgun/SKILL.md
  - reference/gstack/design-consultation/SKILL.md
  - reference/gstack/plan-design-review/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# tac-design

## 何时调用

本 skill 是设计阶段的**唯一入口**，但设计系统**不是 story 的默认产物**。触发方式有两种：

1. **用户主动建立/更新设计系统**
   - 用户说"建立设计系统"、"更新品牌系统"、"/tac-design --mode=system"。
   - 进入**模式 A：建立/更新项目级设计系统**。

2. **story 进入 DESIGN 阶段**
   - 用户说"/tac-design"，或 `/tac-story` 路由到 DESIGN。
   - 先检查 `.aiassist/global/_ds_manifest.json`：
     - **已有设计系统** → 进入**模式 C：迭代 UX 原型**。
     - **没有设计系统** → **不要自动建立**。先问用户：
       - "这个项目还没有设计系统。你是想先建立项目级设计系统（模式 A），还是为这个 story 做临时 UX 探索（模式 C-lite，产物只在 story 内）？"
     - 用户选 A → 进入模式 A。
     - 用户选 C-lite → 进入模式 C，但只做 story 级临时样式，不生成 `.aiassist/global/` 项目设计系统。

3. **用户提供了外部设计源**
   - Figma `.fig`、GitHub 仓库、HTML/CSS 参考。
   - 进入**模式 B：导入设计来源**，导入后再让用户选择用途。

如果 PRD 里某功能完全没有 UI（纯后台逻辑），跳过本 skill，直接 `/tac-crystallize`。

## 输入

- `.aiassist/stories/<id>/prd.md`（模式 C 必需）
- `.aiassist/stories/<id>/workflow-state.yaml`
- 项目设计系统状态：`.aiassist/global/` 下是否有 `_ds_manifest.json`
- 可选：Figma `.fig` 文件、GitHub 仓库 URL、HTML/CSS 参考、竞品截图、品牌 deck

## 输出

模式 A → `.aiassist/global/` 项目级设计系统。  
模式 B → `.aiassist/design-refs/<name>/`。  
模式 C → `.aiassist/stories/<id>/ux/` story 级原型。  
模式 C-lite → `.aiassist/stories/<id>/ux/` story 级原型 + 临时 `tokens.css`（不写入 `.aiassist/global/`）。

## 执行步骤

### 0. 判断模式

读取 `.aiassist/global/_ds_manifest.json` 和 PRD，初步判断应进入哪种模式。

**但必须先向用户确认，不能自动执行。** 用一句话说明检测到的状态和推荐模式，例如：

> "检测到已有设计系统 `xxx`，当前 story 的 PRD 需要 UI，建议进入模式 C：迭代 UX 原型。要设计哪些流程？"
> "这个项目还没有设计系统。你是想先建立项目级设计系统（模式 A），还是为这个 story 做临时 UX 探索（模式 C-lite）？"
> "你提供了 Figma 文件，建议进入模式 B：导入设计来源。导入后想采纳为项目设计系统，还是仅作 story 参考？"

- 用户主动要求建立/更新设计系统 → 模式 A。
- story DESIGN 阶段且无 `_ds_manifest.json` → 问用户：模式 A 还是模式 C-lite。
- 用户提供外部设计源 → 模式 B，导入后让用户选择后续路径。
- 有 `_ds_manifest.json` + PRD 需要 UI → 模式 C。

**得到用户明确回复后，再进入对应模式。**

---

## 模式 A：建立/更新项目级设计系统

设计系统是**高权重产物**，必须由人驱动、来源优先。AI 不能凭空定品牌。

### A.1 检查现有设计系统

- 是否存在 `.aiassist/global/DESIGN.md`？
- 是否存在 `.aiassist/global/tokens.css`？
- 是否存在 `.aiassist/global/_ds_manifest.json`？
- 是否存在 `.aiassist/global/_d_meta.json`？
- 是否有导入参考 `.aiassist/design-refs/<name>/`？

### A.2 判断处理路径

- 如果 `DESIGN.md` + `tokens.css` + `_ds_manifest.json` + `_d_meta.json` 都存在且用户未要求更新 → 告知设计系统已就绪，可打开 `preview.html` 查看。
- 如果只有 `DESIGN.md` + `tokens.css`、缺少编译产物 → 直接进入 A.6 跑编译管线。
- 如果缺失或不全 → 进入 A.3，但**不要直接生成文件**。

### A.3 收集来源与品牌输入

**先问来源，再问调性。** 没有来源时，至少要有人明确回答的品牌问题。

1. **来源问题**：
   - 有没有 Figma `.fig` 文件、GitHub 设计系统仓库、现有 HTML/CSS/网站、品牌 deck、竞品截图？
   - 有的话，路径/URL 是什么？访问权限是否已准备好？

2. **调性问题**（在没有来源或来源不足时必填）：
   - 产品调性是什么？（专业/活泼/高端/亲和/粗犷/极简等）
   - 目标用户是谁？年龄、职业、使用场景？
   - 有没有必须遵守的品牌色、品牌字体、Logo？
   - 平台优先级？（iOS/web/Android 等）
   - 是否需要主题变体？（暗色、高密度等）
   - 有没有竞品或参考应用？

**如果用户没有提供任何来源且回答模糊，不要继续生成。** 停下来要求补充，或建议先 `/tac-research` 做竞品/参考研究。

### A.4 确认范围后再开始

根据 A.3 的回答，向用户说明：

- 将采用哪些来源
- 将生成哪些产物（`DESIGN.md`、`tokens.css`、字体、`components/`、cards、preview）
- 哪些决策需要用户中途确认（token、字体、核心组件）

得到用户明确同意后，再进入 A.5。

### A.5 提取与生成设计系统源文件

**有来源时**：按 baoyu-design 的提取流程读取来源，提取颜色、字体、间距、圆角、阴影、交互状态、图标、Logo，写入 `.aiassist/global/`。

**无来源时**：基于用户回答的调性，先生成最小可迭代版本（MVP 设计系统）：

- `DESIGN.md`：设计原则、token 值、组件形态、情绪调性、来源记录。
- `tokens.css`：CSS 自定义属性，使用 `/* @kind color|font|spacing|radius|shadow|z|motion|other */` 注释帮助 checker 分类。
- `styles.css`：仅 `@import "./tokens.css";` + 少量工具类。
- `README.md`：设计系统概览、来源、内容清单、使用方式。
- 可选 `components/*.jsx` + `*.d.ts` + `*.prompt.md`
- 可选 `cards/*.html`（第一行 `<!-- @dsCard group="..." name="..." viewport="..." -->`）
- 可选 `screens/<screen>/index.html`（第一行 `<!-- @startingPoint section="..." ... -->`）

参考模板：`templates/design-system/global/`。

### A.6 中途确认关键决策

在继续跑编译管线之前，**先让用户确认核心 token 和字体**：

- 打开/展示 `tokens.css` 和 `DESIGN.md` 的关键段落。
- 问："这些颜色、字体、调性是否符合你的品牌预期？"
- 如果有字体文件缺失，明确告诉用户并询问替代方案。

用户确认后再进入 A.7。如果用户有修改意见，先修改再确认。

### A.7 运行编译管线

```bash
node scripts/design-system/compile-design-system.mjs .aiassist/global
node scripts/design-system/check-design-system.mjs .aiassist/global
node scripts/design-system/build-preview.mjs .aiassist/global --out .aiassist/global/preview.html
```

### A.8 记录资产并自导入

```bash
node scripts/design-system/record-asset.mjs .aiassist/global preview.html --name "Design System Preview" --status approved
node scripts/design-system/import-design-system.mjs .aiassist/global .aiassist/global --primary
```

自导入创建 `.aiassist/global/_ds/<slug>/` 与 `_ds_prompt.md`，并在 `_d_meta.json` 中标记 `primaryDesignSystem`。

### A.9 更新 workflow-state（如适用）

```yaml
design_system:
  compiled: true
  slug: <slug>
  preview: .aiassist/global/preview.html
```

### A.10 提示下一步

- 若当前是 story 的 DESIGN 阶段 → 进入模式 C 迭代 UX。
- 若只是建立/更新项目设计系统 → 完成，建议用户打开 `preview.html`  review。

---

## 模式 B：导入设计来源

### B.1 询问并确认导入源类型

**不要假设用户要导入什么。** 先问：

- 要导入哪种来源？
  - Figma `.fig` 文件
  - GitHub 仓库 URL
  - 已有 HTML/CSS 文件或目录
- 导入后想怎么用？（采纳为项目设计系统 / 仅作 story 参考）

得到用户明确回答后，再进入对应 B-figma / B-github / B-htmlcss 流程。

### B.2 流程 B-figma

依赖：`reference/baoyu-design/skills/baoyu-design/agents/import-figma.mjs`

1. 检查依赖存在：`test -f reference/baoyu-design/skills/baoyu-design/agents/import-figma.mjs`
2. 扫描文件内容：`node reference/baoyu-design/skills/baoyu-design/agents/import-figma.mjs outline <file.fig>`
3. 挂载为设计参考：`node reference/baoyu-design/skills/baoyu-design/agents/import-figma.mjs mount <file.fig> .aiassist/design-refs/<name> --pages <a,b>`
4. 需要具体组件时 materialize：`node reference/baoyu-design/skills/baoyu-design/agents/import-figma.mjs materialize <file.fig> --out .aiassist/design-refs/<name>/components --components Button,Input`
5. 需要看效果时 render（谨慎，HTML 很大）：`node reference/baoyu-design/skills/baoyu-design/agents/import-figma.mjs render <file.fig> --frame <guid> --out .aiassist/design-refs/<name>/frame.html`

### B.3 流程 B-github

1. 浏览结构：`gh api repos/<owner>/<repo>/git/trees/HEAD?recursive=1 | jq -r '.tree[] | "\(.path) \(.type)"'`
2. 确认范围：哪些文件/目录是设计相关的？
3. 稀疏导入：`gh api repos/<owner>/<repo>/contents/<path> --jq '.content' | base64 -d > .aiassist/design-refs/<name>/<filename>`
4. 记录来源：在 `.aiassist/design-refs/<name>/README.md` 中记录 URL、路径、日期、许可证。

### B.4 流程 B-htmlcss

1. 读代码而非截图。
2. 从 CSS 中提取颜色、字体、间距、圆角、阴影、交互状态。
3. 复制图片/图标/字体到 `.aiassist/design-refs/<name>/assets/`。
4. 输出 `tokens.css`。
5. 记录来源。

### B.5 确认用途后再流转

导入完成后，向用户展示关键提取结果（主要颜色、字体、组件清单），并问：

- 想采纳为项目设计系统（进入模式 A 做整合）？
- 还是仅作 story 参考（进入模式 C）？

得到明确回答后再流转。

---

## 模式 C：迭代 story 级高保真 HTML UX 原型

### C.1 检查设计系统

- 查找 `.aiassist/global/_ds_manifest.json`。
- 如果有 → 读取 `_ds_manifest.json`、`_ds/<slug>/_ds_prompt.md`，导入全局设计系统到 story。
- 如果没有 → 进入**模式 C-lite**：story 级临时样式，不归入 `.aiassist/global/`。

### C.2 收集设计上下文

- 询问用户是否有截图、Figma `.fig`、GitHub 仓库、HTML/CSS 参考。
- 如有外部源 → 进入模式 B 导入，再回来。

### C.3 确认设计范围后再生成

**在生成任何 HTML 之前，先向用户提问并等待回答：**

- 哪些屏幕/流程需要设计？
- 要几个方案？探索什么维度？
- 遵循现有模式还是新颖大胆？
- 无品牌约束时遵循[前端审美指引](#前端审美指引)。

得到用户明确回答后，再进入 C.4 及以下步骤。**禁止根据 PRD 直接静默生成原型。**

### C.4 检查模块/服务边界

UI 流程常常暴露模块耦合问题。把发现的边界问题反馈回 PRD 第 6.1 节，必要时回流 `/tac-to-prd`。

### C.5 导入全局设计系统（模式 C）或建立临时样式（模式 C-lite）

**模式 C**：

```bash
node scripts/design-system/import-design-system.mjs .aiassist/global .aiassist/stories/<id>/ux --primary
```

**模式 C-lite**：在 `.aiassist/stories/<id>/ux/tokens.css` 中定义最小临时 token，不写入 `.aiassist/global/`。明确告诉用户这是 story 级临时样式，不成为项目设计系统。

### C.6 生成第一版 HTML 原型

- 默认 HTML-native 源：plain HTML/CSS/JS，引用 `ux/_ds/<slug>/styles.css`（模式 C）或 `ux/tokens.css`（模式 C-lite）。
- 需要复杂交互时才用 React + Babel Standalone。
- story 局部 JSX 组件放在 `ux/components/*.jsx` + `*.d.ts`。
- 每个 `.html` 第一行：`<!-- @dsCard group="..." name="..." viewport="..." -->`。
- 参考模板：`templates/story/ux/flow.html.template`。

### C.7 运行 story 级编译管线

```bash
node scripts/design-system/compile-design-system.mjs .aiassist/stories/<id>/ux
node scripts/design-system/check-design-system.mjs .aiassist/stories/<id>/ux
node scripts/design-system/build-preview.mjs .aiassist/stories/<id>/ux --out .aiassist/stories/<id>/ux/preview.html
```

### C.8 记录资产

```bash
node scripts/design-system/record-asset.mjs .aiassist/stories/<id>/ux <flow>.html --name "<Flow Name>" --status needs-review
```

### C.9 呈现与迭代

- 通过 localhost 预览：`python3 -m http.server 4311 --directory .aiassist/stories/<id>/ux`
- 让用户打开 `preview.html` 或具体 `flow.html`。
- 根据反馈迭代，每次修改后重新跑 C.7-C.8。
- 如需多方案对比，用 design-canvas 组件并排展示。
- 如需变体，在 `ux/variants/<name>/` 下创建目录并跑完整管线。

### C.10 双轨收割

- **行为/结构决策** → 更新 PRD 稳定块，必要时重新 `/tac-crystallize`。
- **视觉/交互决策** → 保留在 HTML 中，作为后续 **feel-signoff**（实现并 QA 之后）的参照。不是现在签核。

### C.11 更新 workflow-state

标记 DESIGN 阶段完成，记录 `design_system.slug`、`assets.recorded`、`variants.active`。

### C.12 提示下一步

DESIGN 阶段完成后，**不要直接进入 `/tac-signoff --stage=feel`**。正确顺序是：

1. 更新 `workflow-state.yaml`，把 `phase` 设为 `TECH-DESIGN`。
2. 由 `/tac-story` 路由到 `/tac-tech-design`，继续技术方案设计。
3. 后续依次经过 `CRYSTALLIZE` → `TEST` → `ASSERTION-SIGNOFF` → `BUILD` → `QA`。
4. BUILD 和 QA 都完成后，才进入 `/tac-signoff --stage=feel` 依据本 skill 产出的 HTML 原型验收观感。

如果 DESIGN 阶段发现 PRD 需要大调，先回流 `/tac-to-prd`。

---

## 统一纪律

- **设计系统由人驱动、来源优先。** AI 不能凭空定品牌；没有来源或明确输入时不生成项目级设计系统。
- **模式判断和关键决策必须先向用户确认，禁止自动执行文件生成。**
- DESIGN 阶段**不写测试、不写实现代码**。
- HTML 是思考工具，不是最终实现。
- 主观判断（"好看""舒服"）留在 HTML 里，由 Gate 2 人判。
- 新功能必须回流 PRD，不能直接从 HTML 跳进代码。
- 设计系统 token 是绑定的——不发明系统外颜色或样式；如需新 token，回到模式 A。
- 每次修改源文件后必须重新跑 compile + check + build-preview。
- 所有导入内容必须记录来源。
- 源码优先是 HTML/CSS/JS；React + Babel 仅用于复杂状态/交互。

## 前端审美指引

当设计不受现有品牌系统约束时：

- **调性**：选一个极端方向——极简/极繁/复古未来/有机自然/奢华/玩趣/编辑风/粗野主义/Art Deco/柔和粉彩/工业实用。
- **字体**：选独特有品格的字体，避免 Inter/Roboto/Arial。展示字体 + 正文字体配对。
- **颜色**：主导色 + 锐利强调色优于均匀分布。用 CSS 变量保持一致性。
- **动效**：聚焦高影响力时刻——一次精心编排的页面加载胜过零散微交互。
- **空间**：不对称、重叠、对角线流动、大量留白或受控密度。
- **背景**：渐变网格、噪点纹理、几何图案、叠层透明。

### 避免 AI 俗套

- 不滥用渐变背景、emoji、圆角卡片+左边框强调色。
- 不用 Inter/Roboto/Arial/Fraunces 等过度使用的字体。
- 不用 SVG 手绘替代图片——用占位符并请用户提供真实素材。
- 不填充无意义的数据/图标/统计数字。

## 产物路径

- 项目级设计系统：`.aiassist/global/`
- 导入参考：`.aiassist/design-refs/<name>/`
- story 级原型：`.aiassist/stories/<id>/ux/`

## 与相邻 skill 的关系

| Skill | 边界 |
|---|---|
| `/tac-to-prd` | 提供 PRD 作为设计输入；设计发现的模块耦合问题回流给它。 |
| `/tac-research` | 若对设计系统/组件库/设计源不熟，先产出调研笔记，再进入本 skill。 |
| `/tac-crystallize` | DESIGN 阶段完成后，若 PRD 稳定块已更新，可能需要重新结晶。 |
| `/tac-signoff --stage=feel` | 依据本 skill 产出的 HTML 原型验收观感。 |

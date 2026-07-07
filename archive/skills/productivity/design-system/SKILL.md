---
name: design-system
description: 建立或更新项目级设计系统。生成 HTML-native 源（DESIGN.md、tokens.css、styles.css、可选 JSX 组件与 @dsCard 卡片），并运行 baoyu-design 编译管线产出 _ds_bundle.js、_ds_manifest.json、_ds_prompt.md、preview.html 与 _d_meta.json。
disable-model-invocation: true
sources:
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/design-system-authoring-guide.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/create-design-system.md
  - reference/baoyu-design/skills/baoyu-design/built-in-skills/use-design-system.md
  - reference/baoyu-design/skills/baoyu-design/agents/compile-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/check-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/build-preview.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/import-design-system.mjs
  - reference/baoyu-design/skills/baoyu-design/agents/record-asset.mjs
  - workflow/design/test-as-contract-workflow.md
---

# design-system

## 何时调用

- `/bootstrap-workflow` 初始化项目时发现没有设计系统。
- `/ux-explore` 开始 DESIGN 阶段时发现 `.aiassist/global/_ds_manifest.json` 缺失。
- 用户主动说"建立设计系统"、"更新设计系统"、"/design-system"时。

## 输入

- 项目现有设计资料（品牌色、字体、已有 UI 截图、竞品参考、Figma/GitHub/HTML 参考等）
- 用户的审美偏好（可选）
- PRD 中的用户画像和产品定位
- 已导入的参考：`.aiassist/design-refs/<name>/`（可选）

## 输出

写入 `.aiassist/global/`：

- `DESIGN.md` — 人读的设计系统文档
- `tokens.css` — CSS token 入口（**HTML-native 源**）
- `styles.css` — 全局样式入口（仅 `@import` + 少量工具类）
- `README.md` — 设计系统概览，用于生成 `_ds_prompt.md`
- `components/*.jsx` + `*.d.ts` + `*.prompt.md` — 可复用 JSX 组件（可选）
- `cards/*.html` — `@dsCard` 预览卡片（可选）
- `screens/*/` — `@startingPoint` 起始页面（可选）
- `_ds_bundle.js` — 编译产物：组件 bundle
- `_ds_manifest.json` — 编译产物：命名空间/组件/卡片/token/字体清单
- `_adherence.oxlintrc.json` — 编译产物：实现侧 CSS prop 白名单
- `preview.html` — 编译产物：自包含预览页
- `_ds/<slug>/` — import 产物：运行时拷贝 + `_ds_prompt.md`
- `_d_meta.json` — import/record 产物：设计系统绑定与资产注册

## 执行步骤

1. **检查现有设计系统**：
   - 是否存在 `.aiassist/global/DESIGN.md`？
   - 是否存在 `.aiassist/global/tokens.css`？
   - 是否存在 `.aiassist/global/_ds_manifest.json`？
   - 是否存在 `.aiassist/global/_d_meta.json`？
   - 是否有导入参考 `.aiassist/design-refs/<name>/`？
2. **判断处理路径**：
   - 如果 `DESIGN.md` + `tokens.css` + `_ds_manifest.json` + `_d_meta.json` 都存在且用户未要求更新 → 告知用户设计系统已就绪，可打开 `preview.html` 查看，退出。
   - 如果只有 `DESIGN.md` + `tokens.css`、缺少编译产物 → 直接进入步骤 5（跑编译管线）。
   - 如果缺失或不全 → 进入建设流程（步骤 3）。
3. **访谈用户**（如需要新建）：
   - 产品调性是什么？（专业/活泼/高端/亲和等）
   - 目标用户是谁？
   - 有没有必须遵守的品牌色/字体？
   - 有没有竞品或参考应用？
   - 平台优先级？（iOS/web/Android 等）
   - 是否需要主题变体？（暗色、高密度等）
4. **生成设计系统源文件**：
   - `DESIGN.md`：markdown，包含 token 值、组件形态、情绪调性。
   - `tokens.css`：CSS 自定义属性，使用 `/* @kind color|font|spacing|radius|shadow|z|motion|other */` 注释帮助 checker 分类。
   - `styles.css`：仅 `@import "./tokens.css";` + 少量工具类，不内嵌具体规则。
   - `README.md`：设计系统概览、来源、内容清单、使用方式。
   - 可选 `components/*.jsx` + `*.d.ts` + `*.prompt.md`：组件模块、类型契约、用法提示。
   - 可选 `cards/*.html`：每张卡片第一行必须是 `<!-- @dsCard group="..." name="..." viewport="..." -->`。
   - 可选 `screens/<screen>/index.html`：第一行 `<!-- @startingPoint section="..." ... -->`。
   - 参考模板：`templates/design-system/global/`。
5. **运行编译管线**：
   ```bash
   node scripts/design-system/compile-design-system.mjs .aiassist/global
   node scripts/design-system/check-design-system.mjs .aiassist/global
   node scripts/design-system/build-preview.mjs .aiassist/global --out .aiassist/global/preview.html
   ```
   - `compile` 生成 `_ds_bundle.js`、`_ds_manifest.json`、`_adherence.oxlintrc.json`。
   - `check` 是只读验证，失败时修复源文件再重新 compile。
   - `build-preview` 生成自包含 `preview.html`。
6. **记录资产**：
   ```bash
   node scripts/design-system/record-asset.mjs .aiassist/global preview.html --name "Design System Preview" --status approved
   ```
7. **自导入（生成消费端产物）**：
   ```bash
   node scripts/design-system/import-design-system.mjs .aiassist/global .aiassist/global --primary
   ```
   - 这会创建 `.aiassist/global/_ds/<slug>/`（运行时拷贝）与 `_ds_prompt.md`。
   - 在 `.aiassist/global/_d_meta.json` 中标记 `primaryDesignSystem`。
8. **更新 `workflow-state.yaml`**（当前有 story 时）：
   - `design_system.compiled = true`
   - `design_system.slug = <slug>`
   - `design_system.preview = .aiassist/global/preview.html`
9. **提示下一步**：设计系统已编译并预览就绪。用户可打开 `preview.html`；后续用 `/ux-explore` 生成 story 级原型。

## HTML-native 源纪律

- 设计系统的**源文件**首先是 HTML/CSS/JS：
  - `tokens.css`、`styles.css` 是普通 CSS。
  - `cards/*.html`、`screens/*/` 是普通 HTML。
  - `.jsx` 组件是编译目标，不是唯一源形式。
- React + Babel 仅用于需要复杂交互的组件/原型；卡片和页面优先用原生 HTML。
- 所有编译产物（`_ds_bundle.js`、`_ds_manifest.json`、`_adherence.oxlintrc.json`、`preview.html`）禁止手工编辑；需要变更时改源文件并重新跑管线。

## 变体生成

当用户要求主题/布局/密度变体时：

1. 在 `.aiassist/global/variants/<name>/` 下创建目录。
2. 复制基线 `tokens.css`/`styles.css` 并覆盖需要变化的 token。
3. 对该目录跑完整 compile/check/preview/record。
4. 记录变体到 `.aiassist/global/_d_meta.json`（如 `record-asset.mjs` 支持 `inherit-from`，则指向基线）。

## 与 `/ux-explore` 的关系

- `/design-system` 是项目级、可反复更新的基础设施。
- `/ux-explore` 读取 `.aiassist/global/_ds_manifest.json` 与 `_ds/<slug>/_ds_prompt.md`，将组件/token 用于 story 原型。
- story 原型通过 `ux/_ds/<slug>/` 的运行时拷贝引用设计系统，不直接依赖全局源路径。
- 如需新增全局 token 或组件，先回 `/design-system`，再重新 `/ux-explore`。

## 纪律

- 设计系统是**项目级资产**，不是某个 story 的产物。
- 不要在一个 story 里推翻整个设计系统；如需调整，应回到 `/design-system`。
- `tokens.css` / `styles.css` / `DESIGN.md` / `_ds_manifest.json` 必须保持一致；`_ds_manifest.json` 是前者的机器可读形式。
- 每次修改源文件后必须重新跑 compile + check + build-preview。
- 没有 `_ds_manifest.json` 的设计系统不能进入 `/ux-explore` 的 BUILD 阶段。

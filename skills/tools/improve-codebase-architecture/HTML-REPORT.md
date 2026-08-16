# HTML Report Format

架构评审渲染为系统临时目录下的**单个自包含 HTML 文件**。Tailwind 与 Mermaid 都走 CDN。Mermaid 可靠处理图状图；手工 div 与内联 SVG 处理更编辑化的视觉（mass diagram、cross-section）。两者混用——不要什么都靠 Mermaid，会显得千篇一律。

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review — {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* small custom layer for things Tailwind doesn't cover cleanly:
         dashed seam lines, hand-drawn-feeling arrow heads, etc. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Repo 名、日期、一个紧凑图例：实线框 = module，虚线 = seam，红箭头 = leakage，粗黑框 = deep module。不要引言段——直接进候选。

## Candidate card

图承载分量。散文克制、平实，用 SKILL.md 词汇表术语，不做修饰。

每个候选是一个 `<article>`：

- **Title** — 短，命名深化动作（例："Collapse the Order intake pipeline"）。
- **Badge row** — 推荐强度（`Strong` = emerald，`Worth exploring` = amber，`Speculative` = slate）+ 依赖类别 tag（`in-process`、`local-substitutable`、`ports & adapters`、`mock`）。
- **Files** — 等宽字体列表，`font-mono text-sm`。
- **Before / After diagram** — 核心。两列并排。见下方 patterns。
- **Problem** — 一句话。什么在痛。
- **Solution** — 一句话。会怎么变。
- **Wins** — bullet，每条 ≤6 词。例："Tests hit one interface"、"Pricing logic stops leaking"、"Delete 4 shallow wrappers"。
- **ADR callout**（如有）— 琥珀色框内一行。

不要解释性段落。**如果图需要一段文字才能懂，重画图。**

## Diagram patterns

挑贴合候选的 pattern，混用。不要每张图都一样——多样性本身是重点。

### Mermaid graph（依赖/调用流的得力工具）

用 Mermaid `flowchart` 或 `graph` 表达"X 调 Y 调 Z，看这团乱麻"。包一层 Tailwind 样式卡片让它不显得生硬。用 `classDef` 把泄漏边标红、deep module 标深色。Sequence 图适合"before: 6 round-trips; after: 1"。

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</div>
```

### 手绘盒箭（Mermaid 布局跟你作对时）

Module 用带边框和标签的 `<div>`。箭头用绝对定位的内联 SVG `<line>` / `<path>`，放在 relative 容器上。当你想让"after"图看起来像一个粗边框 deep module、内部灰色淡化时用它——Mermaid 渲染不出这个重量感。

### Cross-section（适合分层浅度）

堆叠横向条带（`h-12 border-l-4`）展示一次调用穿过的层数。Before：6 个薄层各自无事。After：1 个厚条带，标注合并后的职责。

### Mass diagram（适合"interface 和 implementation 一样宽"）

每个模块两块矩形——interface 表面积一块、implementation 一块。Before：interface 矩形几乎和 implementation 一样高（shallow）。After：interface 矩形矮、implementation 矩形高（deep）。

### Call-graph collapse

Before：一个嵌套盒子的函数调用树。After：同一棵树折叠进一个盒子，现在内部化的调用在盒内淡化显示。

## Style guidance

- 编辑化而非 corporate-dashboard。充足留白。标题可选衬线（`font-serif` 与 stone/slate 很搭）。
- 色彩克制：一个 accent（emerald 或 indigo）+ 红色表示 leakage + 琥珀表示警告。
- 图保持 ~320px 高，before/after 才能舒服地并排不滚动。
- 图内模块标签用 `text-xs uppercase tracking-wider`——它们该读作 schematic，不是 UI。
- 唯一脚本是 Tailwind CDN 与 Mermaid ESM import。报告其余静态——无应用代码，除 Mermaid 自身渲染外无交互。

## Top recommendation section

一张更大的卡片。候选名、一句话理由、指向其卡片的锚链接。就这些。

## Tone

平实、简洁的英文——但架构名词和动词直接来自 SKILL.md 词汇表。简洁不是漂移的借口。

**Use exactly:** module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

**Never substitute:** component, service, unit (for module) · API, signature (for interface) · boundary (for seam) · layer, wrapper (for module, when you mean module).

**贴合风格的句式：**

- "Order intake module is shallow — interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in prod, in-memory in tests."

**Wins bullets** 用词汇表术语命名收益：*"locality: bugs concentrate in one module"*、*"leverage: one interface, N call sites"*、*"interface shrinks; implementation absorbs the wrappers"*。别写 *"easier to maintain"* 或 *"cleaner code"*——这些词不在词汇表里，不配占位置。

不写 hedging、不写寒暄、不写 "it's worth noting that…"。一个句子能成 bullet 就成 bullet；一个 bullet 能删就删；一个术语不在词汇表里，先找词汇表里有的，再发明新的。

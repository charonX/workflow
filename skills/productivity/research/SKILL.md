---
name: research
description: 针对一个技术/API/库/领域问题，启动 background agent 读取 primary sources，输出带引用的调研笔记到 story 的 research/ 目录。在技术方案设计前使用（complex story 走 /tech-design），为技术方案提供事实基础。
sources:
  - reference/mattpocock/skills/engineering/research/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# research

## 何时调用

用户在以下场景说"帮我调研一下 X"、"查一下 Y API"、"research Z"、"了解一下某技术"时：

- 准备做技术方案设计（`complex` story 走 `/tech-design`），但对某个技术点/第三方 API/库还不清楚。
- PRD 或技术方案中需要一个外部事实支撑（协议行为、SDK 能力、官方限制等）。
- 想先让 agent 读文档、源码、spec，再基于带引用的笔记做决策。

**不调用的情况**：

- 用户访谈 / 痛点挖掘 → 走 `/demand-insight`。
- 技术方案深潜本身 → 走 `/tech-design`（`complex` story 时）。
- 设计系统 / UX 探索 → 走 `/design`。

## 输入

- `--topic`：调研主题，一句话。例：`Claude Code Marketplace 的 plugin.json schema`。
- `--story`：story-id（可选）。未指定时，使用当前项目 `.aiassist/stories/` 下最近更新的**活动** story（跳过 `status: completed` 的已完成 story）。
- `--sources`：已知的 primary sources 线索（可选）。可以是 URL、仓库路径、文档入口。例：`https://anthropic.com/claude-code/marketplace.schema.json`。

## 输出

`.aiassist/stories/<story-id>/research/<topic-slug>.md`

文件结构见下文[输出格式](#输出格式)。

## 执行步骤

### 1. 解析参数

- `--topic` 必填。若用户只给了一个名词，补成完整问句。例：`Redis 流` → `Redis Stream 的 ACK、消费者组和阻塞读语义`。
- `--story` 可选。未指定时，取 `.aiassist/stories/` 下最近更新的**活动**目录名（跳过 `status: completed` 的已完成 story）。
- `--sources` 可选。用户没给时，由 background agent 自己发现 primary sources。

### 2. 检查并创建目录

```bash
mkdir -p .aiassist/stories/<story-id>/research
touch .aiassist/stories/<story-id>/research/<topic-slug>.md
```

### 3. 启动 background agent 执行调研

使用 `Agent` 工具启动一个名为 `researcher` 的 background agent，任务如下：

> 你是一个严谨的调研员。请针对主题 "<topic>" 进行调研，只读 **primary sources**（官方文档、源码、spec、一手机构 API），不写代码。
>
> 你的工作：
> 1. 识别与主题相关的 primary sources。如果用户提供了线索，优先从那里开始；否则自己搜索。
> 2. 读取这些来源，提取与主题直接相关的事实。
> 3. 每个重要 claim 都必须标注来源（URL + 章节/文件路径）。
> 4. 不确定的地方显式标注 "不确定"，并说明为什么不确定。
> 5. 将结果写入 `.aiassist/stories/<story-id>/research/<topic-slug>.md`，严格遵循输出格式。
> 6. 不要下工程决策，只陈述事实。工程决策由人在技术方案设计中做（`complex` story 走 `/tech-design`）。

允许 researcher 使用的工具：WebFetch、WebSearch、Bash（仅用于读取本地文件或 clone 公开仓库）、Read。

### 4. 等待并汇总

background agent 完成后，读取生成的 markdown 文件，向用户汇报：

- 调研主题
- 输出文件路径
- 主要发现（3-5 条 bullet，带引用）
- 仍存在的开放问题或不确定处
- 建议下一步：补全技术方案（`complex` story 走 `/tech-design`）或继续补充调研

### 5. 不自动消费

**`/research` 只产出笔记，不修改 prd.md。** 后续由 `/to-prd` 或 `/tech-design` 显式读取该笔记并融入决策（写入 `prd.md` §10）。

## 输出格式

```markdown
# Research: <topic>

> 调研日期：<YYYY-MM-DD>
> 主题：<一句话>
> 来源：primary sources（见每节引用）

## 执行摘要

- 3-5 条最重要的发现。
- 每条发现必须带引用，格式：`[source-name](url)` 或 `源码: path/to/file`。

## 详细发现

### <子主题 1>

- <fact 1> — [来源](url)
- <fact 2> — [来源](url)

### <子主题 2>

...

## 不确定 / 待验证

- <问题 1>：为什么不确定，可能需要什么额外信息。
- <问题 2>：...

## 开放问题

- <问题 1>：留给技术方案设计决策（`complex` story 走 `/tech-design`）。
- <问题 2>：...

## 参考来源清单

| 来源 | URL/路径 | 访问日期 | 用途 |
|---|---|---|---|
| Anthropic docs | https://... | 2026-07-06 | plugin.json schema |
| source code | reference/.../file.ts | 2026-07-06 | 内部逻辑 |
```

## 纪律

1. **Primary sources only**：优先官方文档、源码、spec。博客、教程、StackOverflow 只有在官方缺失且明确标注为 secondary 时才使用。
2. **Claim 必须可引用**：任何事实性陈述都要能回溯到具体来源。
3. **不下决策**：research 回答"是什么/能做什么"，不回答"我们应该怎么做"。
4. **不替代访谈**：用户痛点相关的问题回 `/demand-insight`。
5. **输出是临时探索产物**：属于一挡，可被后续技术方案设计（`/tech-design`）推翻或细化。

## 与相邻 skill 的边界

| Skill | 负责 | 不负责 |
|---|---|---|
| `/demand-insight` | 用户痛点、需求边界、隐性假设 | 技术事实 |
| `/research` | 技术/API/库/领域的事实调研 | 工程决策、用户访谈 |
| `/tech-design` | 基于事实做技术方案、模块边界、接口契约 | 读文档找事实 |
| `/to-prd` | 把调研笔记和访谈整合成 PRD | 不做原始调研 |

## 示例

```bash
/research --topic="Claude Code Marketplace plugin.json schema" --story=2026-07-05-marketplace --sources="https://anthropic.com/claude-code/marketplace.schema.json"
```

输出：`.aiassist/stories/2026-07-05-marketplace/research/claude-code-marketplace-plugin-json-schema.md`

---
name: wayfind
description: 探索一个模糊想法——创建决策地图，一次解决一张票，直到方向清晰。是 story 之前的上游探索阶段（可选）。
disable-model-invocation: true
sources:
  - reference/mattpocock/skills/engineering/wayfinder/SKILL.md
---

# wayfind

## 定位

Wayfind 是 story 之前的**可选探索阶段**。输入一个模糊想法，输出一套清晰的决策：

- **要做的事** → 创建 story
- **明确不做的事** → 写 ADR
- **超出本次范围的事** → 归入 Out of scope

```
模糊想法 ──→ /wayfind ──→ 决策集合
                (探索)        │
                   ┌──────────┼──────────┐
                   ▼          ▼          ▼
                /story     /story       ADR
                (做 A)     (做 B)    (不做 C)
```

**和 story 的本质区别：**

| | Wayfind | Story |
|---|---|---|
| 输入 | 模糊想法，"有个方向但不知道是什么" | 明确的痛点，"用户需要 X" |
| 目标 | 把方向搞清楚，判断值不值得做 | 把问题解决掉 |
| 产出 | 决策记录 + 零到多个 story | 可工作的代码 + 测试 |
| 二挡线 | 不需要测试 | REQ → 测试 → 实现 |
| 何时结束 | 前沿为空，没有待决议的票 | QA 全绿，REFLECT 通过 |
| 必选？ | 否——想法足够清晰可直接开 story | 是——执行必走 story |

**关键纪律：Wayfind 做决策，不做实现。** 发现自己在写产品代码 → 该转 story 了。

## 输入

用户的模糊想法。一句话到一段话均可：

- "我想做一个 AI 编码助手"
- "社区运营这块好像可以做点什么"
- "要不要把后端从 REST 换成 GraphQL？"
- "感觉我们应该有一个开发者门户，但不确定"

## 输出

```
.aiassist/wayfind/<name>/
├── map.md                    # 总地图（index，不存细节）
├── tickets/                  # 决策票
│   ├── 01-<slug>.md
│   ├── 02-<slug>.md
│   └── ...
├── research/                 # research 票的产出（按需创建）
└── prototypes/               # prototype 票的产出（按需创建）
```

决议的去向记录在 map 的 Decisions so far 中：

| 决议 | 动作 | 标注 |
|---|---|---|
| 这件事要做 | 创建 story | `→ Story: <id>` |
| 这件事不做 | 写 ADR 到 `.aiassist/global/adr/` | `→ ADR: <number>` |
| 超出范围 | 归入 map 的 Out of scope | `→ Out of scope` |

## 核心概念

### Map（地图）

Map 是一个 **index，不是 store**。每个决策只存在于它的票里，map 只做一句话摘要 + 链接。

Map 文件格式见 [templates/map.md.template](templates/map.md.template)。

### Ticket（决策票）

每张票是一个**待决议的问题**，不是待执行的构建切片。如果一张票在描述"实现 X 功能"，那它应该是 story，不是 wayfind 票。

票文件格式见 [templates/ticket.md.template](templates/ticket.md.template)。

票的类型：

| 类型 | 模式 | 说明 | 方法论来源 |
|---|---|---|---|
| **grilling** | HITL（人机协同） | 对抗式访谈，追方向性问题 | 读 `skills/productivity/demand-insight/SKILL.md` 的访谈技巧，但保持方向性——追"这方向对吗？"而非"完整需求是什么"。决议直接写入票的 `## Resolution`，**不写** `interview-notes.md` |
| **research** | AFK（AI 自主） | 读文档/API/源码/知识库，挖出一个事实 | 读 `skills/productivity/research/SKILL.md` 的 primary-source 纪律。输出到 `research/<topic>.md`，票的 Resolution 链接过去并给一句结论 |
| **prototype** | HITL | 做一个低保真 throwaway 原型来激发讨论 | 读 `skills/productivity/design/SKILL.md` Mode C 的 HTML 原型方法。输出到 `prototypes/<name>.html`，票的 Resolution 链接过去，记录从中得到的决策依据 |
| **task** | HITL 或 AFK | 解锁决策必须完成的手工活——申请权限、迁移数据、注册服务 | 做事，做完在 Resolution 记录结果和后续票依赖的事实 |

**HITL vs AFK：** HITL（Human In The Loop）票必须通过真人交互来解决——agent 不能替人回答 grilling 问题、不能替人判断原型好不好。AFK 票 agent 自主完成。

### Fog of War（战争迷雾）

看得见但看不清的区域——你知道有决策要做，但问题本身还不够清晰，无法开票。

- **能精确提问 → 开票**（不管能不能回答）
- **不能精确提问 → 进 Not yet specified（迷雾）**

解决一张票 → 迷雾散去一块 → 新票从迷雾毕业。不要提前把迷雾切成票——一个迷雾块可能毕业成零张、一张或多张票。

### Frontier（前沿）

开放、未被阻塞、未被认领的票——已知世界的边界。

- **开放**：`Status: open`
- **未被阻塞**：`Blocked by` 列出的票都已 resolved
- **未被认领**：`Status` 不是 `claimed`

### Out of scope（明确排除）

工作超出了 Destination 定义的范围。迷雾只向终点聚集，超出终点的不是迷雾，是 Out of scope。

归入这里的工作**不毕业**——除非 Destination 被重画，否则不会变成票或 story。

## 两种模式

### A. Chart the map（绘制地图）

用户带着模糊想法进来，第一次创建地图。

**步骤：**

1. **定 Destination**。用 grilling 方法论追问：这次探索的终点是什么？要澄清的决策？要产出的结论？Destination 定 scope——后面的每一张票都要对照它来判断是否在范围内。

2. **广度优先扫描全貌**。继续 grilling，但这次横扫而非深追：这个方向有哪些需要决策的点？哪些已经有答案？哪些需要先搞清楚才能继续？

3. **判断是否需要 map**。如果扫描后发现方向已经足够清晰、一两句话就能说清要做什么 → **停下来，告诉用户不需要 wayfind**，建议直接开 story。Wayfind 是为迷雾设计的——没有雾就不需要地图。

4. **创建 map 和目录结构**：
   ```
   .aiassist/wayfind/<name>/
   ├── map.md          # 从 templates/map.md.template 填充
   └── tickets/        # 空目录，等待创建票
   ```

5. **创建现在就能精确提问的票**（从 templates/ticket.md.template），作为 map 的子文件。

6. **设置阻塞关系**。票创建后，扫描哪些票依赖其他票的答案，填写 `Blocked by`。

7. **把尚不能精确提问的东西写入 map 的 Not yet specified**。

8. **并行启动所有 research 票**（AFK，可并行）。每张 research 票启动一个子 agent，读 `skills/productivity/research/SKILL.md` 获取 primary-source 纪律，结果写入 `research/<topic>.md`。

9. **停下**。Charting 阶段不解决任何 HITL 票——那是 Work 模式的事。

### B. Work through the map（穿越地图）

用户带着已有 map 进来，继续推进。

**步骤：**

1. **加载 map**。读 `map.md`，获取 Destination、已有决策、当前迷雾。

2. **扫描前沿**。遍历 `tickets/`，找到所有 `Status: open`、未被阻塞、未被认领的票。按编号顺序取第一张。

3. **认领**。将票的 `Status` 改为 `claimed`，保存。防止并发 session 重复工作。

4. **解决**。按票的类型处理（见上方票类型表）。关键原则：
   - **一次 session 最多解决一张 HITL 票**。Research 票例外，可以在 charting 阶段并行，也可以在 work 阶段作为子 agent 异步跑。
   - 需要深入追问时，拉取相关已关闭票的完整内容，按需 zoom in。

5. **记录决议**：
   - 在票文件中追加 `## Resolution`，给出清晰的答案
   - 将 `Status` 改为 `resolved`
   - 在 map 的 `## Decisions so far` 追加一行：`- [票标题](tickets/NN-slug.md) — 一句话摘要`

6. **清扫迷雾**。决议是否让之前看不清的东西变得可指定了？如果：
   - 迷雾块现在能精确提问 → 创建新票，从 Not yet specified 中移除该块
   - 答案显示某票（本票或其他票）超出 Destination → **归入 Out of scope**，关闭该票，不进入 Decisions so far
   - 答案让地图其他部分失效 → 更新或删除相关票

7. **处理决议去向**：
   - 决议是"这件事要做"且范围清晰 → 记录 `→ Story: <id>`，等 wayfind 完成后再统一创建 story（不在 wayfind session 内创建 story，保持边界清晰）
   - 决议是"这件事不做"且有架构/策略意义 → 写 ADR 到 `.aiassist/global/adr/`，记录 `→ ADR: <number>`
   - 决议是纯信息性的（了解到某事实，不影响做/不做） → 只记在 Decisions so far，无额外动作

8. **停下**。如果前沿还有 HITL 票，告诉用户下一张是什么，让用户决定是否继续。

## 完成条件

Wayfind 完成 = **前沿为空**：所有票都已 resolved，Not yet specified 为空或不构成行动障碍。

此时 map 的 Decisions so far 就是全部输出。和用户一起过一遍：

1. 哪些条目要转 story？→ 对每个，调用 `/story` 创建
2. 哪些条目要写 ADR？→ 确保已写入
3. 有没有遗漏的方向？→ 如果 Destination 需要调整，回到 Charting 更新

完成后将 map 末尾添加一行 `Status: completed`。

## 与现有 skill 的关系

Wayfind **引用但不调用**以下 skill 的方法论：

| Skill | 引用方式 |
|---|---|
| `demand-insight` | 读其 SKILL.md 的访谈技巧（HYPOTHESIS/CONFIDENCE、第一性原理追问、边界探测），但保持方向性而非完整性 |
| `research` | 读其 SKILL.md 的 primary-source 纪律（WebFetch + WebSearch，带引用），输出到 wayfind 的 research/ 目录 |
| `design` | 读其 SKILL.md Mode C 的 HTML 原型方法，输出 throwaway 原型到 wayfind 的 prototypes/ 目录 |

**不在 wayfind 内调用的原因**：这些 skill 的输出路径绑定 story 目录（`.aiassist/stories/<id>/`）。Wayfind 在 story 之前，没有 story-id。引用方法论 + 覆盖输出路径 = 复用知识但不污染目录。

**Wayfind 完成后的过渡**：用户确认哪些条目转 story 后，正式调用 `/story` 创建。此时 `/story` → `/demand-insight` 正常写入 story 目录，不再有冲突。

## 纪律

- **一次一票**：每个 session 最多解决一张 HITL 票。Research 票例外。
- **票是问题，不是任务**：票的内容是"X 应该怎么做？"而不是"实现 X"。后者该转 story。
- **不提前切票**：看不清的不硬切。放在 Not yet specified，等前面的票解决后自然毕业。
- **Destination 即边界**：每次认领票前对照 Destination——这票在范围内吗？不在 → Out of scope。
- **wayfind 不产生代码**：prototype 票产出的是 throwaway HTML，不是产品代码。
- **转 story 是显式动作**：wayfind 完成后再统一创建 story，不在 wayfind session 内混用。

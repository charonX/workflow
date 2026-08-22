# 循环

> 一个人 + AI 的软件开发工作流。

AI 写代码的速度早就不缺了。真正难的是：**它交的东西，你怎么敢信是对的？**

直接改代码、直接喊"这里改一下"，都会被 AI 的误解吞掉——它当初就是误解了你才写错的，你再用嘴纠正，它可能接着误解。所以这个工作流把纠错接口换掉：**你要判断的"什么算对"，写进 PRD 和测试里；AI 对着这些标准把代码磨到全绿。** 你不再盯着代码挑毛病，而是改需求、改验收标准来纠错——错误回到源头修，不在代码里打补丁。

这不是某个 IDE 或模型的专属插件，而是一套能落到任何项目、任何 Agent 工具链的理念和纪律。它站在一堆开源项目（见文末）的肩膀上，把"需求 → 规格 → 测试 → 实现 → 验收"拼成一条适合**个人创作者 / 小团队**的完整流水线。

---

## 一句话理解

工作流分两层，一层你控制，一层 AI 控制：

- **外层循环——你想清楚做什么**：需求访谈 → PRD → UX 原型 → 领域建模 → 技术方案 → 验收标准。这层慢工出细活，全是你的决定。
- **内层循环——AI 自主实现**：读测试 → 写代码 → 跑测试 → 改 bug → 全绿。这层你不用盯着，AI 在测试构成的契约里自己磨。

两个循环之间有"门"：

| 门 | 干什么 |
|---|---|
| **门 1 · 断言签核** | REQ 和测试生成后，把契约交给 AI 实现。默认 AI 自己检查；只有它拿不准的事（契约矛盾、安全边界、要不要新建 story）才来问你 |
| **门 2 · 反思** | 全部测试绿、bug 处理完之后，你最终验收，顺便沉淀经验 |

**一句话哲学**：还在开发中的 story，PRD 和测试是权威，AI 对着它们实现；story 完成后，代码和测试就是当前行为的真值，当初的"为什么"记在全局文档里（ADR、能力地图、术语表）。story 的 spec 目录随删除提交进 git 历史，工作区不留——需要回溯时 `git show` 即可。

---

## 一次开发大概这么走

从模糊想法到上线，大约 13 步。前面 8 步是把"做什么、怎么算对"定清楚，中间 AI 实现，最后你验收：

| # | 阶段 | 干什么 | 谁 |
|---|---|---|---|
| 0 | WAYFIND（可选） | 模糊想法 → 拆成清晰的 story 列表 | 你 |
| 1 | THINK | 对抗式访谈，把隐性需求、边界、矛盾逼出来 | 你 + AI |
| 2 | PRD | 整理成结构化文档（含技术方案、验收锚点） | 你 |
| 3 | DESIGN | HTML 原型探索 UX，边搭边推翻 | 你 |
| 4 | DOMAIN-MODEL | 统一领域术语和业务实体 | 你 |
| 5 | TECH-DESIGN | 技术方案深潜（仅复杂 story） | 你 + AI |
| 6 | CRYSTALLIZE | 稳定块 → 带 ID 的 REQ + 验收标准 | AI |
| 7 | TEST | 从 REQ 生成测试（预期值追到 PRD 锚点） | AI |
| 8 | ASSERTION-SIGNOFF | 自动签核，把契约交给 AI（拿不准才问你） | AI |
| 9 | BUILD | 对着测试实现，磨到全绿 | AI |
| 10 | QA | 回归 + 证据收集 | AI |
| 11 | BUG | 修 bug：诊断根因 → 你分类 → 修 / 补测试 / 就地补全 | 你 + AI |
| 12 | REFLECT | 最终验收 + 沉淀经验 | 你 |

注意第 6–8 步是一个**自动链**：你跑一次 `/story`，AI 一口气把 REQ、测试、签核全做完，中途不停。前面 PRD 和 DESIGN 做扎实了，这几步就是机械翻译。

开发中期还有个"两挡"的概念：**一挡**是探索期（PRD、HTML 原型，随便推翻，零成本）；**二挡**是测试锁定期（定了 REQ，改动都要有测试兜底）。跨过"不再推翻"这条线，才进入二挡。

---

## 四条不能动的底线

这套东西有几个前提，任何 skill 都不能绕过：

1. **测试先于实现**：REQ → 测试 → 代码，顺序锁死。测试是实现前就画好的靶子，不是实现后补的。
2. **实现者碰不到测试**：AI 不能为了刷绿而改测试——这是防作弊的结构保证。
3. **测试全绿 ≠ 做对了**：实现还得对得上 PRD 的意图。BUILD 里有专门的一步检查"测试绿了但意图没落地"。
4. **初衷锚点**：一个 story 对应一个痛点（初衷）。方案可以换，痛点不换。发现方向错了，回到根因层重来，不硬撑。

---

## 为什么它能自动那么多

你可能会嘀咕：前面说 REQ、测试、实现都是 AI 的机械活，凭什么信？

因为你把"什么算对"的**预期值**直接写进了 PRD——例子里给输入要出什么、接口契约的输入输出、字段校验规则。AI 生成测试时，每个断言的预期值必须**追到 PRD 里那行字**（测试文件里标 `EXPECTED-TRACE`）。追不到，说明 PRD 有洞——AI 补上，或者来问你。这样测试不是 AI 自己编的，是从你的规格里翻译出来的。**反作弊靠的是这条"可追溯"，不是靠人盯。**

另外，验收时发现问题不用推倒重来。工作流默认的收敛方式是**就地补全**：缺什么补什么（PRD、REQ、测试），补完继续跑。真到方向错了的地步（初衷不成立），才走"回流"——归档重做，或者删掉这个 story。

---

## 怎么开始用

有三种装法，挑一种顺手的。装完都能用 `/bootstrap-workflow`、`/story` 这套命令。

### 方式一：Claude Code 插件（推荐）

在你的项目会话里直接敲：

```bash
/plugin marketplace add charonX/workflow    # 添加本仓库为 marketplace（只需一次）
/plugin install loop-workflow@charonx-workflow
/reload-plugins
```

> 升级：`/plugin marketplace update charonx-workflow` 拉取最新目录，再 `/reload-plugins`。

### 方式二：Kimi Code 插件

```bash
/plugins install https://github.com/charonX/workflow
```

装完 `/reload` 或新开会话生效。用 `/skill:story`、`/skill:bootstrap-workflow` 这类方式触发。

### 方式三：npm（npx skills）

```bash
npx skills@latest add charonX/workflow
```

### 方式四：手动复制（本地有克隆）

```bash
cd /path/to/your-project
rm -rf .claude/skills/*
cp -R /path/to/workflow/skills/productivity/* .claude/skills/
cp -R /path/to/workflow/skills/engineering/* .claude/skills/
cp -R /path/to/workflow/skills/tools/* .claude/skills/
```

装好后，在项目里开干：

```bash
/bootstrap-workflow    # 初始化项目基础设施（.aiassit/）
/story                 # 开始第一个 story
```

**升级**：skill 更新走对应插件的更新命令；项目里的 `.aiassit/` 内容更新，直接重跑 `/bootstrap-workflow`——它检测到已存在的项目会自动进入升级模式（更新没改过的模板文件、替换 CLAUDE.md 附录、修 CI 已知问题；被你定制过的文件会保留，并提示手动合并）。

> 装好后，项目的 `CLAUDE.md` 会追加一份工作流附录，里面是该项目所有可用 skill 的速查表。更详细的安装（含软链、跨平台迁移、保持同步）见 [`docs/install.md`](./docs/install.md)。

---

## Skill 一览

### 你触发的

| Skill | 干嘛的 |
|---|---|
| `/story` | 总入口：开始 / 继续 / 回流一个 story |
| `/wayfind` | 探索模糊想法，拆成 story 列表 |
| `/bootstrap-workflow` | 初始化项目基础设施（也是升级入口） |
| `/demand-insight` | 对抗式需求访谈 |
| `/to-prd` | 把讨论整理成 PRD |
| `/tech-design` | 技术方案深潜（仅复杂 story） |
| `/domain-model` | 统一领域术语 |
| `/design` | 设计统一入口：建设计系统、导入设计源、迭代 HTML 原型 |
| `/bug` | 单 bug 人机协同：诊断根因 → 分类 → 修 / 补测试 / 就地补全 |
| `/review` | 手动审查：按层并行派 specialist 审 PRD/技术方案/REQ/测试/代码，汇总一份报告 |
| `/signoff` | 门 1：断言签核（默认 AI 自检，升级点问你） |
| `/reflect` | 门 2：最终验收 + 沉淀经验 |
| `/research` | 带引用的技术调研 |
| `/design-handoff` | 从已批准 UX 生成开发交接包 |

### AI 触发的

| Skill | 干嘛的 |
|---|---|
| `/crystallize` | PRD 稳定块 → REQ-ID |
| `/test-author` | 生成测试骨架，预期值追到 PRD 锚点 |
| `/tdd` | 内层实现纪律：RED → GREEN 写单元测试 |
| `/implementer` | 对着已签测试实现代码 |
| `/qa-runner` | 跑回归 / E2E，收集证据 |
| `/browser-verify` | 浏览器运行时验证（Chrome DevTools） |

### 独立工具

| Skill | 干嘛的 |
|---|---|
| `/improve-codebase-architecture` | 扫描代码库找架构深化机会 |
| `/wizard` | 把只有人能做的步骤固化成 bash 向导 |
| `/resolving-merge-conflicts` | 解决 git 合并冲突 |

完整速查表见本仓库 `CLAUDE.md`。

---

## 项目里会长出什么

初始化后，项目里会出现一个 `.aiassit/` 目录：

```
.aiassit/
├── global/          # 跨 story 的长期资产：能力地图、术语表、ADR、检查清单、标准
└── stories/         # 每个 story 一个目录：PRD、REQ、测试计划、签核记录、UX 原型
```

- `global/` 里的东西会一直攒下去，是项目的"意图层"——新 story 靠它对齐上下文。
- `stories/<id>/` 是单个 story 的产物。story 完成后整个目录提交删除（进 git 历史），以后逻辑看代码 + 测试、意图看 `global/`。

---

## 参考项目

这个工作流不是从零发明的，是把下面这些项目的想法拼起来的。它们各自解决了一层问题：

| 项目 | 我们借鉴了什么 |
|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) | 工程纪律：单一 spec、垂直切片、TDD 红绿、对抗式文档审查 |
| [gstack](https://github.com/garrytan/gstack) | 需求洞察、设计决策、QA 门禁、浏览器自动化、流程编排 |
| [superpowers](https://github.com/obra/superpowers) | 严谨计划、subagent 批量执行、审查包 |
| [baoyu-design](https://github.com/JimLiu/baoyu-design) | HTML 原型方法论、设计系统编译管线、Figma 导入 |
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) | 生产级工程生命周期 skill、specialist 审查 persona、共享检查清单 |

---

## 深入阅读

- 理念的推导过程：[`design/test-as-contract-workflow.md`](./design/test-as-contract-workflow.md)
- 框架总装图：[`design/workflow-framework.md`](./design/workflow-framework.md)
- 决策记录：[`design/adr/`](./design/adr/)
- 完整安装与升级：[`docs/install.md`](./docs/install.md)

---

## 许可证

MIT

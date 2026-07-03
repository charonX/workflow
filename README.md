# 测试即契约工作流

[![GitHub](https://img.shields.io/badge/GitHub-charonX%2Fworkflow-blue?logo=github)](https://github.com/charonX/workflow)

一个 Claude Code 插件,用于人机协作开发。核心命题:**AI 自主写代码时,人凭什么敢信它对了?**

答案是把人的纠错接口从"改代码/命令 AI"换成"测试"。人只负责裁定"什么算对",把它编译成机器可验证的契约,AI 在契约内自主迭代。

## 为什么需要它

把"AI 自主写代码"做成可信的关键,不在于让 AI 写得更快,而在于**人怎么纠错**。

直接改代码、或直接命令 AI 改代码,都会被 AI 的误解吞掉——它当初就是误解了你的意图才写错的,你再用自然语言纠正,它可能继续误解。本工作流把人的纠错接口换成**测试**:人持有断言(什么算对),AI 持有脚手架(怎么测),AI 在契约内自主磨到全绿。

人的工作因此整体**上移到 spec 层**。PRD/UX 的精度,直接决定下游能自动化多少——这是整套方法的杠杆点,也是它的全部成本所在。

## 核心理念

> **人持有裁决器(断言);AI 在测试构成的契约内实现。人不直接修改实现代码——他们修改需求和断言,错误逐层回流到最高层。**

五条承重不变量,动任何一条整套方法就塌:

1. **断言归人。** 人只持有"什么算对"这一行判断;AI 持有其余全部脚手架(环境/夹具/选择器/mock/数据)。AI 不得擅改断言。
2. **PRD/REQ 是唯一裁判,也是测试的唯一出生地。** "这是 bug 还是需求变更"靠回溯 REQ 机械裁决,不靠感觉。没有任何测试可以脱离 REQ 存在——连 bug 触发的测试,也是先把 REQ 验收标准补细再派生测试,从结构上杜绝套件腐化。
3. **主观不进测试。** 行为对错由机器判(测试),观感好坏由人判(HTML 视觉参照)。两条纠错回路并存、不打架。
4. **绿灯不许撒谎。** 四层防作弊:角色隔离(测试作者 ≠ 实现者)+ 实现者对测试只读 + 抗特判测试(多输入/基于性质/隐藏保留集)+ 停机条件是"全套绿"而非"功能自己绿"。
5. **人的功夫上移到 spec。** PRD/UX 精度 = 下游自动化的上限。健康度指标:观感签核发现的缺口比例应随时间下降;居高不下 = 需求洞察投入不够。

两条公理贯穿一切:

- **真理只向下流**:PRD(意图)→ REQ(验收标准)→ 测试(可执行契约)→ 代码(实现)。上层是下层的"为什么",下层是上层的"怎么验";代码永远不是真理来源。
- **纠错只向上回**:错误回到"出错的最高那一层"修,绝不在低层就地打补丁。代码不绿→循环内自修;测试漏 case→回 REQ;行为没依据→回 PRD;方向没想清→回一挡。

## 实现方式

### 两挡模型

承认 PRD 不可能一次想清。工作流分两挡,把"停止移动"的东西才固化:

| 挡位 | 时机 | 规则 |
|---|---|---|
| **一挡 — 探索期** | PRD、UX 原型、设计系统 | 可随意推翻,尚无测试,零成本试错 |
| **二挡 — 测试锁定** | REQ-ID 已签核 | 任何变更都必须有通过测试的支撑 |

跨越线 = "某块不再推翻/即将被依赖"。一挡可无限循环;二挡的回报是单人开发最缺的**回归安全网**——你越高频改,网越值钱。

### 十个阶段

| # | 阶段 | Skill | 触发者 | 做什么 |
|---|---|---|---|---|
| 1 | **THINK** | `/tac-demand-insight` | 用户 | 对抗式访谈,暴露隐性需求、边界与矛盾 |
| 2 | **PRD** | `/tac-to-prd` | 用户 | 把讨论整理成结构化 PRD(问题陈述锚定痛点) |
| 3 | **设计系统** | `/tac-design-system` | 用户 | 建立项目级 `.aiassist/global/DESIGN.md` + `tokens.css` |
| 4 | **UX 设计** | `/tac-ux-explore` | 用户 | 迭代高保真 HTML 原型;行为决策进 REQ,视觉决策进 HTML |
| 5 | **结晶** | `/tac-crystallize` | 模型 | 把稳定 PRD 块转成带验收标准的 REQ-ID |
| 6 | **测试** | `/tac-test-author` | 模型 | 从 REQ 生成测试骨架,为人留出占位断言 |
| 7 | **断言签核** | `/tac-assertion-signoff` | 用户 | 人在实现前签核所有断言(门 1) |
| 8 | **实现** | `/tac-implementer` | 模型 | 针对测试实现代码,对测试只读,每轮跑全套测试 |
| 9 | **QA** | `/tac-qa-runner` | 模型 | E2E、回归、证据收集 |
| 10 | **观感签核** | `/tac-feel-signoff` | 用户 | 人依据 HTML 参照验收观感,偏差回流 REQ(门 2) |
| — | **反思** | `/tac-reflect` | 用户 | 捕获经验教训,更新全局知识 |

### 三种角色(权限互斥)

| 角色 | 能写 | 不能写 | 职责 |
|---|---|---|---|
| **人** | REQ、断言、HTML UX | 实现代码 | 画靶子、签断言、验观感、裁决 bug/需求变更 |
| **测试作者 agent** | 测试脚手架 | 实现代码 | 把人签字的断言展开成可执行测试 |
| **实现者 agent** | 实现代码 | 测试(只读) | 在测试契约内自主迭代到全套绿 |

测试作者与实现者**权限互斥**,是"绿灯不撒谎"的结构性保证。

### 两道硬性签核

1. **门 1 — `/tac-assertion-signoff`**:人确认测试准确捕捉了需求。不签不准实现。
2. **门 2 — `/tac-feel-signoff`**:人确认实现后的 UI 观感与批准的 HTML 参照一致。不签不准合并。

人在边界使劲(门 1 签断言、门 2 验观感),中段全自主;失败走逃生口(实现者轮数上限→上报,不许自己改测试)。

### REQ 可追溯性

每个测试文件必须声明:

```
// REQ-TRACE: <story-id>/<req-id>
// REQ-VERSION: <hash>
```

REQ 变 → 挂它的测试标记"过时待重生"。任何失败测试都能回溯到它代表的需求。

### 回流机制

工作流承认一挡会推翻,把"推倒重来"做成显式、留证据、可学习的动作。`/tac-story` 内置回流分支。

**核心:story = 初衷。** 初衷指向用户痛点,不是具体方案(方案会变,痛点不会)。

| 情况 | 动作 |
|---|---|
| 初衷不变,实现路径错了(一挡/二挡都算) | 同 story 下 `archive/` 归档本次尝试,同 story 重做 |
| 初衷本身错了/痛点不成立 | 不归档,直接删 story |

- **归档范围**:PRD、requirements、断言签核、代码等承诺层产物 + `reason.md`(根因+推翻理由)。UX 原型不归档(一挡思考工具,直接改)。
- **根因诊断优先**:回流前先判"初衷在不在"。模型提议,人拍板。
- **不算回流的情况**(走局部纠错):REQ 漏 case → `/tac-crystallize` 补验收标准;断言自相矛盾 → 门 1 重审;一挡内单块推翻 → 该块降级回"移动块"。

## 安装

### 方式一：通过 Claude Code 插件市场安装（推荐）

```bash
npx skills@latest add charonX/workflow
```

### 方式二：手动复制或软链

如果你本地有本仓库的克隆，可以把 `skills/` 目录复制或软链到目标项目的 `.claude/skills/`：

```bash
# 1. 克隆本仓库（如尚未克隆）
git clone https://github.com/charonX/workflow.git

# 2. 复制到目标项目
cd /path/to/your-project
rm -rf .claude/skills/*
cp -R /path/to/workflow/skills/productivity/* .claude/skills/
cp -R /path/to/workflow/skills/engineering/* .claude/skills/
cp -R /path/to/workflow/skills/maintenance/* .claude/skills/

# 或软链(仅本地开发)
ln -s /path/to/workflow/skills/productivity/tac-* .claude/skills/
ln -s /path/to/workflow/skills/engineering/tac-* .claude/skills/
ln -s /path/to/workflow/skills/maintenance/tac-* .claude/skills/
```

### 方式三：安装到 workflow 仓库自身的开发环境

如果你正在修改本仓库的 skill，可以软链到本地测试项目：

```bash
cd /path/to/test-project
rm -rf .claude/skills/*
ln -s /Users/zhanglei/charon/code/workspace/workflow/skills/productivity/tac-* .claude/skills/
ln -s /Users/zhanglei/charon/code/workspace/workflow/skills/engineering/tac-* .claude/skills/
ln -s /Users/zhanglei/charon/code/workspace/workflow/skills/maintenance/tac-* .claude/skills/
```

## 保持同步

当本仓库的 skill 更新后，重新安装到目标项目即可：

```bash
npx skills@latest add charonX/workflow
```

如果你使用本地软链开发，更新会自动生效，无需重新安装。

## 使用

在目标项目中:

```
/tac-bootstrap-workflow    # 初始化项目级工作流基础设施
/tac-story                 # 开始或继续一个 story
```

### 快速上手

```bash
# 1. 安装 skill 到目标项目
npx skills@latest add charonX/workflow

# 2. 初始化项目基础设施
/tac-bootstrap-workflow

# 3. 从需求洞察开始一个新 story
/tac-story

# 4. 按提示走完 PRD → 设计 → REQ → 测试 → 签核 → 实现
```

## Skill 列表

### 用户触发

| Skill | 阶段 | 用途 |
|---|---|---|
| `/tac-story` | 路由 | 开始/继续 story;执行回流(归档重做/删 story) |
| `/tac-bootstrap-workflow` | 初始化 | 创建 `.aiassist/` 项目基础设施 |
| `/tac-demand-insight` | THINK | 对抗式需求访谈 |
| `/tac-to-prd` | PRD | 把讨论整理成 PRD |
| `/tac-design-system` | DESIGN | 建立项目级设计系统 |
| `/tac-design-import` | DESIGN | 导入设计来源(Figma/GitHub/HTML) |
| `/tac-ux-explore` | DESIGN | 迭代高保真 HTML UX 原型 |
| `/tac-assertion-signoff` | 签核 | 在实现前签核断言 |
| `/tac-feel-signoff` | 签核 | 依据 HTML 参照验收观感 |
| `/tac-design-handoff` | 交接 | 从已批准 UX 生成开发交接包 |
| `/tac-reflect` | REFLECT | 捕获经验教训 |

### 模型触发

| Skill | 阶段 | 用途 |
|---|---|---|
| `/tac-crystallize` | 结晶 | 把 PRD 转成 REQ-ID |
| `/tac-test-author` | TEST | 生成测试骨架 |
| `/tac-implementer` | BUILD | 针对测试实现代码 |
| `/tac-qa-runner` | QA | 运行 E2E/回归 |

## 产物目录

```
.aiassist/
├── stories/<story-id>/
│   ├── prd.md
│   ├── requirements.md
│   ├── requirements-v1.hash
│   ├── ux/
│   ├── test-plan.md
│   ├── assertion-signoff.md
│   ├── feel-signoff.md
│   ├── workflow-state.yaml      # phase/attempt/history/archive 状态机
│   └── archive/                 # 归档重做时,被推翻的承诺层产物 + reason.md
└── global/
    ├── DESIGN.md                # 项目级设计系统文档
    ├── tokens.css               # 可运行的 CSS token
    ├── engineering-lessons.md
    ├── architecture.md
    └── STANDARDS.md
```

模板放在 `templates/`,由 `/tac-story` 创建新 story 时复制使用。

## 参考项目

本工作流综合了以下开源项目的思想。我们不重造骨架,只把骨架里"BUILD/纠错"那一段换成更严的纪律内核。

| 项目 | 借鉴了什么 | 我们的差异 |
|---|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) | 工程纪律:红绿重构、对抗式文档审查、诊断 | 加上"断言归人、REQ 是测试唯一出生地"的纯粹派纪律 |
| [gstack](https://github.com/garrytan/gstack) | CEO/创始人级需求洞察、设计决策、发布与 QA 门禁、浏览器自动化、流程编排与产物链 | 把"office-hours/qa/ship"的前进式流程,补上显式的回流与 story 生命周期管理 |
| [superpowers](https://github.com/obra/superpowers) | 严谨计划、subagent 驱动的批量执行、审查包 | 计划稳定性假设换成"一挡会推翻",把推翻做成结构化动作 |
| [baoyu-design](https://github.com/JimLiu/baoyu-design) | Claude Design 可移植 skill:HTML 原型方法论、设计系统、Figma 导入、起始组件 | 吸收其 HTML 原型与设计系统能力,绑定到我们的 `tokens.css` 视觉约束 |

### 我们补的是"测试信任层"

这些参考项目不是没有测试——它们各有 TDD、QA、审查机制。它们缺的是:**把"什么算对"这个 oracle 锚定在"人持有、且 AI 无法作弊"的断言上。**

| 维度 | 参考项目 | 我们 |
|---|---|---|
| 北极星 | **吞吐**:AI 基本可信,给流程脚手架让它多出活 | **自主下的信任**:读不完 AI 的代码,凭什么敢信它对了 |
| 测试地位 | 下游质量门 | 上游契约(脊柱) |
| oracle | 文档 + AI 判断 | 人持有的断言 + AI 仅做脚手架 |
| 代价 | 放弃部分信任换吞吐 | 牺牲部分吞吐(人签断言)换"不读代码也敢信" |
| 适配 | 有 QA/能抽查的团队 | 单人/OPC——读不完,信任是真瓶颈 |

我们的研究贡献:不是"参考项目 + 更好的测试",而是给这个领域补上它整体缺失的一层——**AI 自主下,如何把测试 oracle 锚定在人持有、抗作弊的断言上**。

> 理念的逐条推导见 [`design/test-as-contract-workflow.md`](./design/test-as-contract-workflow.md),端到端流程总装图见 [`design/workflow-framework.md`](./design/workflow-framework.md)。

## 许可证

MIT

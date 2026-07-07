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

### 十二个阶段

| # | 阶段 | Skill | 触发者 | 做什么 |
|---|---|---|---|---|
| 1 | **THINK** | `/tac-demand-insight` | 用户 | 对抗式访谈,暴露隐性需求、边界与矛盾 |
| 2 | **PRD** | `/tac-to-prd` | 用户 | 把讨论整理成结构化 PRD(问题陈述锚定痛点) |
| 3 | **DESIGN** | `/tac-design` | 用户 | 统一入口:建/更新设计系统、导入设计源、迭代 HTML 原型 |
| 4 | **技术方案** | `/tac-tech-design` | 用户 | 对抗式设计模块、数据流、接口契约与 CLI 优先的测试 seams |
| 5 | **技术方案审查** | `/tac-review --stage=tech` | 用户（手动） | 新会话视角审查技术方案（可选但建议） |
| 6 | **结晶** | `/tac-crystallize` | 模型 | 把稳定 PRD 块转成带验收标准的 REQ-ID |
| 7 | **测试** | `/tac-test-author` | 模型 | 从 REQ + tech-design 优先生成 CLI 测试骨架,再按需补单元/E2E,为人留占位断言 |
| 8 | **断言签核** | `/tac-signoff --stage=assertion` | 用户 | 人在实现前签核所有断言(门 1) |
| 9 | **实现** | `/tac-implementer` | 模型 | 针对测试实现代码,对测试只读,每轮跑全套测试 |
| 10 | **代码审查** | `/tac-review --stage=code` | 用户（手动） | 新会话视角审查实现 diff（可选但建议） |
| 11 | **QA** | `/tac-qa-runner` | 模型 | E2E、回归、证据收集 |
| 12 | **观感签核** | `/tac-signoff --stage=feel` | 用户 | 人依据 HTML 参照验收观感,偏差回流 REQ(门 2) |
| — | **反思** | `/tac-reflect` | 用户 | 捕获经验教训,更新全局知识 |

### 三种角色(权限互斥)

| 角色 | 能写 | 不能写 | 职责 |
|---|---|---|---|
| **人** | REQ、断言、HTML UX | 实现代码 | 画靶子、签断言、验观感、裁决 bug/需求变更 |
| **测试作者 agent** | 测试脚手架 | 实现代码 | 把人签字的断言展开成可执行测试 |
| **实现者 agent** | 实现代码 | 测试(只读) | 在测试契约内自主迭代到全套绿 |

测试作者与实现者**权限互斥**,是"绿灯不撒谎"的结构性保证。

### CLI 作为默认测试 seam

除非项目明显是纯浏览器 C 端且没有任何后台行为,否则优先把产品 CLI 当作首要测试 seam:

- **CLI 是人类和 agent 共用的真实接口**。测试在跑的命令,就是人可以手动跑的命令,避免"测试专用路径"与"真实用户路径"分叉。
- **可观察行为优先**:CLI 测试断言 stdout/stderr/exit code/文件 side effect/数据库状态,不窥视实现细节。
- **状态保持友好**:CLI 可以守护长期状态(数据库、配置、会话),测试之间不用反复启停,比浏览器 E2E 更稳定。
- **缺陷下沉**:能用 CLI 验证的行为,不进浏览器 E2E;不能 CLI 化的复杂前端交互,才退到单元测试或浏览器 E2E。

因此 `/tac-tech-design` 会默认问:"这个稳定块能否映射到产品 CLI 的某个命令?"`/tac-test-author` 会优先生成 CLI 测试,再按需补充单元/E2E 测试。

### 两道硬性签核

1. **门 1 — `/tac-signoff --stage=assertion`**:人确认测试准确捕捉了需求。不签不准实现。
2. **门 2 — `/tac-signoff --stage=feel`**:人确认实现后的 UI 观感与批准的 HTML 参照一致。不签不准合并。

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

### 方式一：通过 Claude Code Marketplace 安装（推荐）

在任意项目的 Claude Code 会话中：

```bash
# 1. 添加本仓库作为 marketplace（只需一次）
/plugin marketplace add charonX/workflow

# 2. 安装插件
/plugin install test-as-contract-workflow@charonx-workflow

# 3. 安装后刷新插件
/reload-plugins
```

>  marketplace 名是 `charonx-workflow`，插件名是 `test-as-contract-workflow`。
>  后续更新：先 `/plugin marketplace update charonx-workflow` 拉取最新目录，再 `/reload-plugins` 重载；必要时可 `/plugin uninstall test-as-contract-workflow@charonx-workflow` 后重新安装。

### 方式二：通过 `npx skills` 安装（Vercel Labs skills CLI）

```bash
npx skills@latest add charonX/workflow
```

### 方式三：手动复制或软链

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

## 保持同步

当本仓库的 skill 更新后：

- **Marketplace 方式**：`/plugin marketplace update charonx-workflow`
- **npx skills 方式**：`npx skills@latest add charonX/workflow`
- **本地软链开发**：更新会自动生效，无需重新安装

## 使用

在目标项目中:

```
/tac-bootstrap-workflow    # 初始化项目级工作流基础设施
/tac-story                 # 开始或继续一个 story
```

### 快速上手

```bash
# 1. 添加 marketplace 并安装插件
/plugin marketplace add charonX/workflow
/plugin install test-as-contract-workflow@charonx-workflow
/reload-plugins

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
| `/tac-demand-insight` | THINK | 对抗式需求访谈；用第一性原理剥离继承假设，适合只有模糊痛点或初步想法的阶段 |
| `/tac-to-prd` | PRD | 把讨论整理成 PRD |
| `/tac-tech-design` | TECH-DESIGN | 对抗式技术方案设计；用第一性原理区分真实约束与历史包袱，确定 CLI 优先的 seams |
| `/tac-research` | THINK/TECH | 针对技术/API/库问题做带引用的 background 调研 |
| `/tac-review` | REVIEW | 手动审查 PRD/技术方案/代码（建议新会话） |
| `/tac-design` | DESIGN | 设计阶段统一入口：建/更新设计系统、导入设计源、迭代 HTML UX 原型 |
| `/tac-signoff` | 签核 | assertion 阶段签核断言；feel 阶段依据 HTML 参照验收观感 |
| `/tac-design-handoff` | 交接（可选） | 从已批准 UX 生成开发交接包（含机器可读 manifest） |
| `/tac-reflect` | REFLECT（可选） | 捕获经验教训 |

### 模型触发

| Skill | 阶段 | 用途 |
|---|---|---|
| `/tac-crystallize` | 结晶 | 把 PRD 转成 REQ-ID |
| `/tac-test-author` | TEST | 优先生成 CLI 测试骨架，再按需补单元/E2E，为人留占位断言 |
| `/tac-implementer` | BUILD | 针对测试实现代码 |
| `/tac-qa-runner` | QA | 运行 E2E/回归 |

## 产物目录

```
.aiassist/
├── stories/<story-id>/
│   ├── prd.md
│   ├── tech-design.md         # 技术方案（一挡可推翻）
│   ├── requirements.md
│   ├── requirements-v1.hash
│   ├── research/                  # （可选）/tac-research 输出的调研笔记
│   │   └── <topic-slug>.md
│   ├── ux/
│   │   ├── *.html                 # HTML 原型（带 @dsCard 标签）
│   │   ├── components/            # （可选）story 局部 JSX 组件
│   │   ├── _ds_bundle.js          # （生成）story 组件 bundle
│   │   ├── _ds_manifest.json     # （生成）story 设计系统清单
│   │   ├── preview.html           # （生成）自包含预览页
│   │   ├── _d_meta.json          # （生成）资产注册表 + 设计系统绑定
│   │   └── _ds/<slug>/            # （生成）全局设计系统运行时拷贝
│   ├── design_handoff/
│   │   ├── README.md              # 开发交接文档
│   │   └── _handoff_manifest.json # 机器可读交接清单
│   ├── test-plan.md
│   ├── signoff.md             # 断言签核 + 观感签核记录
│   ├── workflow-state.yaml      # phase/attempt/history/archive 状态机
│   └── archive/                 # 归档重做时,被推翻的承诺层产物 + reason.md
└── global/
    ├── DESIGN.md                # 项目级设计系统文档
    ├── tokens.css               # CSS token 入口
    ├── styles.css               # 全局样式入口（仅 @import + 工具类）
    ├── README.md                # 设计系统概览
    ├── components/              # （可选）JSX 组件 + .d.ts 契约
    ├── cards/                   # （可选）@dsCard 预览卡片
    ├── screens/                 # （可选）@startingPoint 起始页面
    ├── _ds_bundle.js           # （生成）编译后的组件 bundle
    ├── _ds_manifest.json       # （生成）设计系统清单
    ├── _adherence.oxlintrc.json# （生成）实现侧 CSS prop 白名单
    ├── preview.html            # （生成）自包含交互预览
    ├── _ds/<slug>/             # （生成）运行时拷贝 + _ds_prompt.md
    ├── _d_meta.json            # （生成）设计系统绑定与资产注册
    ├── engineering-lessons.md
    ├── architecture.md
    └── STANDARDS.md
```

模板放在 `templates/`,由 `/tac-story` 创建新 story 时复制使用。

## 参考项目

本工作流是以下开源项目思想与个人实践的组合。每个项目解决了不同层面的问题，我们把它们拼接成一条完整的单人开发流水线。

| 项目 | 我们借鉴了什么 |
|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) | 工程纪律：TDD 红绿重构、对抗式文档审查、诊断方法 |
| [gstack](https://github.com/garrytan/gstack) | CEO/创始人级需求洞察、设计决策、发布与 QA 门禁、浏览器自动化、流程编排与产物链 |
| [superpowers](https://github.com/obra/superpowers) | 严谨计划、subagent 驱动的批量执行、审查包 |
| [baoyu-design](https://github.com/JimLiu/baoyu-design) | Claude Design 可移植 skill：HTML 原型方法论、设计系统编译管线、Figma 导入、起始组件 |

> 理念的逐条推导见 [`design/test-as-contract-workflow.md`](./design/test-as-contract-workflow.md)，端到端流程总装图见 [`design/workflow-framework.md`](./design/workflow-framework.md)。

## 许可证

MIT

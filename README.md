# 测试即契约工作流

一个 Claude Code 插件，用于人机协作开发：测试即契约。

## 核心理念

> 人持有裁决器（断言）；AI 在测试构成的契约内实现。人不直接修改实现代码 —— 他们修改需求和断言，错误逐层回流到最高层。

## 安装

```bash
npx skills@latest add <your-github-username>/test-as-contract-workflow
```

或者把 `skills/` 目录复制/软链到目标项目的 `.claude/skills/`：

```bash
# 复制
cp -R /path/to/workflow/skills/* .claude/skills/

# 或软链（仅本地开发）
ln -s /path/to/workflow/skills/* .claude/skills/
```

## 工作流概览

工作流分**两挡**、**十个阶段**。目标是在人签核之前保持探索便宜，签核之后由测试锁定。

### 两挡

| 挡位 | 时机 | 规则 |
|---|---|---|
| **一挡 — 探索期** | PRD、UX 原型、设计系统 | 可随意推翻，尚无测试 |
| **二挡 — 测试锁定** | REQ-ID 已签核 | 任何变更都必须有通过测试的支撑 |

两挡之间的跨越发生在人签核断言之后。此前自由迭代；此后 AI 针对已签核测试写代码，且实现者对测试只读。

### 十个阶段

| # | 阶段 | Skill | 触发者 | 做什么 |
|---|---|---|---|---|
| 1 | **THINK** | `/demand-insight` | 用户 | 对抗式访谈，暴露隐性需求、边界与矛盾 |
| 2 | **PRD** | `/to-prd` | 用户 | 把讨论整理成结构化 PRD |
| 3 | **设计系统** | `/design-system` | 用户 | 建立项目级 `.aiassist/global/DESIGN.md` + `.aiassist/global/tokens.css` |
| 4 | **UX 设计** | `/ux-explore` | 用户 | 迭代高保真 HTML 原型；行为决策进 REQ，视觉决策进 HTML |
| 5 | **结晶** | `/crystallize` | 模型 | 把稳定 PRD 块转成带验收标准的 REQ-ID |
| 6 | **测试** | `/test-author` | 模型 | 从 REQ 生成测试骨架，为人留出占位断言 |
| 7 | **断言签核** | `/assertion-signoff` | 用户 | 人在实现前签核所有断言 |
| 8 | **实现** | `/implementer` | 模型 | 针对测试实现代码，对测试只读，每轮跑全套测试 |
| 9 | **QA** | `/qa-runner` | 模型 | E2E、回归、证据收集 |
| 10 | **观感签核** | `/feel-signoff` | 用户 | 人依据 HTML 参照验收观感，偏差回流 REQ |
| — | **反思** | `/reflect` | 用户 | 捕获经验教训，更新 `.aiassist/global/` 知识 |

### 硬性签核点

有两处必须得到人的明确批准：

1. **`/assertion-signoff`** —— 人确认测试准确捕捉了需求。
2. **`/feel-signoff`** —— 人确认实现后的 UI 观感与批准的 HTML 参照一致。

### REQ 可追溯性

每个测试文件必须声明：

```
// REQ-TRACE: <story-id>/<req-id>
// REQ-VERSION: <hash>
```

这样任何失败的测试都能回溯到它所代表的需求。

## 使用

在目标项目中：

```
/bootstrap-workflow    # 初始化项目级工作流基础设施
/test-as-contract      # 开始或继续一个 story
```

### 快速上手

```bash
# 1. 把 skill 安装到目标项目
npx skills@latest add <your-github-username>/test-as-contract-workflow

# 2. 初始化项目基础设施
/bootstrap-workflow

# 3. 从需求洞察开始一个新 story
/test-as-contract

# 4. 按提示走完 PRD → 设计 → REQ → 测试 → 签核 → 实现
```

## Skill 列表

### 用户触发

| Skill | 阶段 | 用途 |
|---|---|---|
| `/test-as-contract` | 路由 | 开始/继续 story；强制签核 |
| `/bootstrap-workflow` | 初始化 | 创建 `.aiassist/` 项目基础设施 |
| `/demand-insight` | THINK | 对抗式需求访谈 |
| `/to-prd` | PRD | 把讨论整理成 PRD |
| `/design-system` | DESIGN | 建立项目级设计系统 |
| `/ux-explore` | DESIGN | 迭代高保真 HTML UX 原型 |
| `/assertion-signoff` | 签核 | 在实现前签核断言 |
| `/feel-signoff` | 签核 | 依据 HTML 参照验收观感 |
| `/reflect` | REFLECT | 捕获经验教训 |

### 模型触发

| Skill | 阶段 | 用途 |
|---|---|---|
| `/crystallize` | 结晶 | 把 PRD 转成 REQ-ID |
| `/test-author` | TEST | 生成测试骨架 |
| `/implementer` | BUILD | 针对测试实现代码 |
| `/qa-runner` | QA | 运行 E2E/回归 |

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
│   └── workflow-state.yaml
└── global/
    ├── DESIGN.md              # 项目级设计系统文档
    ├── tokens.css             # 可运行的 CSS token
    ├── engineering-lessons.md
    ├── architecture.md
    └── STANDARDS.md
```

## 模板

模板放在 `templates/`，由 `/test-as-contract` 创建新 story 时复制使用。

## 参考来源

本工作流综合了以下项目的思想：

- [mattpocock/skills](https://github.com/mattpocock/skills) —— 工程纪律
- [gstack](https://github.com/gstackio/gstack) —— CEO/创始人洞察与发布
- [soflow](https://github.com/geekplus/soflow) —— 流程与产物链
- [superpowers](https://github.com/prime-radiant-inc/superpowers) —— 计划与 subagent 执行

## 许可证

MIT

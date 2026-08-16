---
name: architecture-vocabulary
description: 共享的 deep-module 架构词汇（module/interface/seam/depth/leverage/locality + 四原则 + 依赖四分类）。供需要模块/接口/深度评估的 skill 引用；当前消费者：improve-codebase-architecture。随 skills/tools/ 一起安装分发。
sources:
  - reference/mattpocock/skills/engineering/codebase-design/SKILL.md
  - reference/mattpocock/skills/engineering/codebase-design/DEEPENING.md
---

# 架构词汇（deep-module 词汇表）

共享语言基础：设计 **deep modules**——大量行为藏在小的 interface 后面，置于干净的 seam，透过该 interface 可测。目标 = 对调用者的 leverage、对维护者的 locality、对所有人的 testability。用这套词汇命名与评估，保持术语一致。

## 术语表

用这些术语，不要替换为 component/service/API/boundary。

| 术语 | 定义 | 避免 |
|---|---|---|
| **Module** | 任何有 interface + implementation 的东西，刻意 scale-agnostic（函数/类/包/跨层切片） | unit, component, service |
| **Interface** | 调用者正确使用所需知道的一切：签名 + 不变量、顺序约束、错误模式、配置、性能特征 | API, signature（太窄，只指类型层） |
| **Implementation** | 模块内部。与 Adapter 区分：adapter 描述"角色"（填哪个槽），implementation 描述"内容" | — |
| **Depth** | interface 处的 leverage：每单位需要学习的 interface 能驱动多少行为。deep = 大行为藏在小 interface 后；shallow = interface 复杂度≈implementation | 行数比（Ousterhout，奖励 padding） |
| **Seam** | 不改代码就能改变行为的位置；interface 所在之处 | boundary（与 DDD bounded context 冲突） |
| **Adapter** | 在 seam 处满足 interface 的具体物，描述角色而非内容 | — |
| **Leverage** | 调用者收益：一个 implementation 回报 N 个调用点 + M 个测试 | "easier to maintain" |
| **Locality** | 维护者收益：变更/bug/知识/验证集中一处，fix once, fixed everywhere | "cleaner code" |

## Deep vs shallow

**Deep module** = 小 interface + 大量 implementation：

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**Shallow module** = 大 interface + 少量 implementation（避免）：

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

设计 interface 时三问：能减少方法数吗？能简化参数吗？能藏更多复杂度进去吗？

## 四原则

1. **Depth 是 interface 的属性，不是 implementation 的**。深模块可以内部由小的、可 mock 的、可替换的部分组成——它们只是不属于 interface。模块可以有内部 seam（私有、供自身测试）与外部 seam（interface 处）。
2. **Deletion test**：假想删掉模块——复杂度消失说明是 pass-through；复杂度在 N 个调用者处重现说明它物有所值。
3. **The interface is the test surface**：调用者和测试过同一个 seam；想"绕过 interface 测内部"说明模块形状错了。
4. **One adapter = hypothetical seam, two = real**：没有真实变化就不要引入 seam。

## 依赖四分类

评估候选时给依赖归类，类别决定深化后的模块怎么跨 seam 测试：

| 类别 | 判定 | 测试策略 |
|---|---|---|
| in-process | 纯计算/内存态，无 I/O | 直接合并，透过新 interface 测，无需 adapter |
| local-substitutable | 有本地替身（PGLite、内存文件系统） | 用替身跑测试；seam 内部化，模块外部无 port |
| remote-but-owned（ports & adapters） | 自己的跨网络服务 | 在 seam 定义 port；逻辑在 deep module，transport 注入为 adapter；测试用 in-memory adapter |
| true-external（mock） | 第三方服务（Stripe/Twilio） | 注入为 port；测试用 mock adapter |

## 测试策略：replace, don't layer

- 深化模块的 interface 测试就位后，浅层模块的旧单测变成废品——删掉。
- 新测试写在深化模块的 interface 上（**interface 是 test surface**）。
- 测试断言 interface 可观察结果，不测内部状态。
- 测试应能存活于内部重构——若实现变了测试就要变，说明在测 interface 之外。

## 来源

改编自 mattpocock `codebase-design`（含 `DEEPENING.md`）。本文件是共享词汇 reference，不作为独立 skill 注册。

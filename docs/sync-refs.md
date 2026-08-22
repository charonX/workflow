# 同步参考项目（仓库内部维护）

> 本文是 `loop-workflow` **仓库自身**的维护指南，不随 skill 分发。它替代原 `/sync-refs` skill（已移出分发的 workflow，因为 `reference/` 只存在于本仓库，终端项目用不到）。

本仓库把流行开源 agent-skill 项目的副本放在 `reference/`（只读，只供灵感）。上游会持续更新，本指南说明如何拉取、对比、决定吸收哪些变化到 `skills/`。

## 何时同步

- 定期维护：**每月一次**，或某个 reference 项目有大版本发布时。
- 想吸收某个 reference 变更前，先看看它改了什么。
- 耗时通常 5–15 分钟——大部分时候没有需要吸收的变更。

## 第一步：运行脚本生成报告

```bash
./scripts/sync-refs.sh
```

脚本会：

1. `git fetch` + `git merge --ff-only` 所有 reference 仓库。
2. 解析每个 skill 的 `SOURCES.md`，提取它依赖哪些 reference 文件。
3. 对每个依赖，`git log --since=<上次同步>` 检查是否有新提交。
4. 生成 `docs/sync-reports/YYYY-MM-DD.md`。

参数：`--pull-only`（只拉不生成报告）/ `--report-only`（不拉，只对比生成报告）。

## 第二步：阅读报告

报告结构：

```
# 同步报告 — 2026-07-01 10:00

## 参考仓库状态        ← 每个 ref 仓库当前 HEAD

## 变更按 skill 分组
### `ux-explore`                  ← skill 名称
- 🔄 `reference/baoyu-design/...` ← 有变更（显示提交记录）
   a1b2c3d 2026-06-28 ...        ← 具体提交
- ✅ `reference/gstack/...`       ← 无变更
- ⚠️  `reference/some-repo/deleted-file.md`  ← 文件已不存在（上游移动或删除）

## 待处理事项
```

## 第三步：逐项判断（吸收 / 跳过 / 稍后）

对报告中每个 🔄 或 🆕 项：

1. **读变更**：`git -C reference/<repo> diff <since>..HEAD -- <file>`
2. **判断**：
   - **吸收**：改动对我们的 workflow 有意义 → 进入第四步。
   - **跳过**：改动无关（内部实现细节、我们不用的功能）→ 记录跳过。
   - **稍后**：需要更多上下文判断 → 标记，下次再看。

判断时考虑：

- 这个改动是否改进了 skill 的核心方法论？
- 我们之前借鉴的那部分有没有变？
- 改动是否与我们已有的改编冲突？

### 判断原则

| 情况 | 处理 |
|------|------|
| Reference 新增了技能/功能，我们没借鉴过 | **跳过**，除非有明确需求 |
| Reference 修改了我们借鉴过的方法论 | **仔细评估**，通常值得吸收 |
| Reference 修复了缺陷或改进了格式 | **吸收**，低风险高收益 |
| Reference 重构了内部实现 | **跳过**，不影响方法论 |
| Reference 文件被删除/移动 | **标记**，检查是否影响我们的引用 |
| 改动与我们的改编冲突 | **分析冲突**，优先保持我们的设计决策 |

## 第四步：吸收变更

对决定吸收的变更：

1. **打开对应 skill 文件**：`skills/<bucket>/<name>/SKILL.md`。
2. **阅读 reference diff**，理解改了什么。
3. **改编到我们的 skill**：
   - 保持我们的文风、结构、命名。
   - **只吸收与我们 workflow 相关的部分**。
   - 不破坏已有的 test-as-contract 流程约束（四道承重墙不可配置）。
4. **更新 `SOURCES.md` 的"改动记录"**：
   ```markdown
   - YYYY-MM-DD：吸收 <reference> 的 <改动描述>
     - 具体改动：...
   ```
5. **更新 skill 的 `sources:` frontmatter**（如有新增的参考文件）。

## 第五步：提交

```bash
git add skills/ docs/sync-reports/ .aiassist/global/sync-refs-state.json
git commit -m "sync-refs: absorb upstream changes from <repo> — <summary>"
```

## 首次运行

首次运行时没有上次同步时间戳，脚本会把所有依赖标记为 🆕（首次检查）。这不意味着需要全部评审——只是建立基线。之后只会显示增量变更。

## 依赖与纪律

- 依赖：`scripts/sync-refs.sh`（需可执行权限）、`python3`（解析 state）、`git`、reference 仓库需有网络访问权限。
- 纪律：
  - **不盲目吸收所有变更**——每个改动都需要人判。
  - 吸收后必须更新 `SOURCES.md` 记录。
  - **不修改 `reference/` 仓库中的文件**（只读灵感来源，复制模式到 `skills/` 时写 `SOURCES.md`）。
  - reference fetch 失败（网络问题）→ 报告失败，不阻塞。

---
name: sync-refs
description: 拉取所有 reference 项目最新代码，检查每个 skill 的参考依赖是否有上游变更，生成变更报告并引导逐项判断是否吸收。
disable-model-invocation: true
---

# sync-refs

## 何时调用

- 用户说"同步 reference"、"/sync-refs"、"检查上游更新"、"更新 workflow"
- 定期维护（建议每月一次，或某个 reference 项目有大版本发布时）
- 在吸收 reference 变更前想先了解有什么变化

## 输入

- `reference/` 下的 git 仓库
- `skills/*/SOURCES.md` 中的参考依赖声明
- `.aiassist/global/sync-refs-state.json`（上次同步时间戳）

## 输出

- `docs/sync-reports/YYYY-MM-DD.md` — 结构化变更报告
- 更新 `.aiassist/global/sync-refs-state.json`
- 用户决定吸收的变更 → 更新对应 skill 的 SKILL.md 和 SOURCES.md

## 执行步骤

### 第一步：运行脚本生成报告

```bash
./scripts/sync-refs.sh
```

脚本会：
1. `git fetch` + `git merge --ff-only` 所有 reference 仓库
2. 解析每个 skill 的 `SOURCES.md`，提取它依赖哪些 reference 文件
3. 对每个依赖，`git log --since=<上次同步>` 检查是否有新提交
4. 生成 `docs/sync-reports/YYYY-MM-DD.md`

### 第二步：阅读报告

报告结构：

```
# 同步报告 — 2026-07-01 10:00

## 参考仓库状态        ← 每个 ref 仓库当前 HEAD

## 变更按 skill 分组              ← 按 skill 分组

### `ux-explore`                  ← skill 名称
- 🔄 `reference/baoyu-design/...` ← 有变更（显示提交记录）
   a1b2c3d 2026-06-28 ...       ← 具体提交
- ✅ `reference/gstack/...`       ← 无变更
- ⚠️  `reference/gstack/design-system/SKILL.md`      ← 文件已不存在

## 待处理事项                 ← 处理指引
```

### 第三步：逐项判断

对报告中每个 🔄 或 🆕 项：

1. **读变更**：`git -C reference/<repo> diff <since>..HEAD -- <file>`
2. **判断**：
   - **吸收**：改动对我们的 workflow 有意义 → 进入第四步
   - **跳过**：改动无关（如内部实现细节、我们不用的功能）→ 记录跳过
   - **稍后**：需要更多上下文判断 → 标记，下次再看

判断时考虑：
- 这个改动是否改进了 skill 的核心方法论？
- 我们之前借鉴的那部分有没有变？
- 改动是否与我们已有的改编冲突？

### 第四步：吸收变更

对决定吸收的变更：

1. **打开对应 skill 文件**：`skills/<bucket>/<name>/SKILL.md`
2. **阅读 reference diff**，理解改了什么
3. **改编到我们的 skill**：
   - 保持我们的文风、结构、命名
   - 只吸收与我们 workflow 相关的部分
   - 不破坏已有的 test-as-contract 流程约束
4. **更新 SOURCES.md** 的"改动记录"：
   ```markdown
   - YYYY-MM-DD：吸收 <reference> 的 <改动描述>
     - 具体改动：...
   ```
5. **更新 skill 的 `sources:` frontmatter**（如有新增的参考文件）

### 第五步：提交

```bash
git add skills/ docs/sync-reports/ .aiassist/global/sync-refs-state.json
git commit -m "sync-refs: absorb upstream changes from <repo> — <summary>"
```

## 判断原则

| 情况 | 处理 |
|------|------|
| Reference 新增了技能/功能，我们没借鉴过 | **跳过**，除非有明确需求 |
| Reference 修改了我们借鉴过的方法论 | **仔细评估**，通常值得吸收 |
| Reference 修复了缺陷或改进了格式 | **吸收**，低风险高收益 |
| Reference 重构了内部实现 | **跳过**，不影响方法论 |
| Reference 文件被删除/移动 | **标记**，检查是否影响我们的引用 |
| 改动与我们的改编冲突 | **分析冲突**，优先保持我们的设计决策 |

## 首次运行

首次运行时没有上次同步时间戳，脚本会将所有依赖标记为 🆕（首次检查）。这不意味着需要全部评审——只是建立基线。之后只会显示增量变更。

## 定期维护建议

- **频率**：每月一次，或 reference 项目大版本发布时
- **耗时**：通常 5-15 分钟（大部分时候没有需要吸收的变更）
- **触发**：`/sync-refs`

## 依赖

- `scripts/sync-refs.sh`（需可执行权限）
- `python3`（解析 JSON state 文件）
- `git`（拉取和 diff reference 仓库）
- reference 仓库需有网络访问权限

## 纪律

- 不盲目吸收所有变更——每个改动都需要人判。
- 吸收后必须更新 SOURCES.md 记录。
- 不修改 reference 仓库中的文件。
- 如果 reference 仓库 fetch 失败（网络问题），报告失败不阻塞。

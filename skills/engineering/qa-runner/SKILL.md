---
name: qa-runner
description: 内层实现循环的终点验证。BUILD 全绿后跑 E2E/回归、收集证据、输出 QA 报告,为 feel-signoff 提供客观依据。
sources:
  - reference/gstack/qa/SKILL.md
  - reference/gstack/qa-only/SKILL.md
  - reference/superpowers/skills/subagent-driven-development/SKILL.md
  - workflow/design/test-as-contract-workflow.md
---

# qa-runner

## 何时调用

BUILD 阶段全单元绿，进入 QA 慢外门时。或被 `/story` 总入口调用。

## 输入

- 实现代码
- 测试文件（项目对应位置，如 `tests/**/*.test.ts`、`*Tests/**/*.swift` 等）
- `.aiassist/stories/<id>/requirements.md`

## 输出

- `.aiassist/stories/<id>/qa-report.md`
- 截图/日志证据（可选）

## 执行步骤

1. **跑单元测试**：确认仍全绿。
2. **跑 E2E/UITests**：验证关键用户流程。
   - 如果项目使用 Playwright，先检查：
     - `playwright` 是否已安装
     - 浏览器二进制是否已安装（如缺失，提示运行 `npx playwright install --with-deps chromium`）
     - `playwright.config.ts` 是否存在
   - 运行 `npx playwright test`（或项目约定的 Playwright 命令）。
   - 收集失败测试列表、trace 路径、screenshot 路径。
   - 区分"连续失败"（blocker）与"retry 后通过"（flaky）。
3. **运行时浏览器验证（可选）**：如果本 story 有 `ux/` 目录且 Chrome DevTools MCP 已配置，调用 `/browser-verify` 收集 Console/DOM/Network/Accessibility/截图证据。未配置时记录为 SKIPPED。
4. **收集 coverage 报告**：对比项目 coverage 阈值，低于阈值时 QA 不通过。
5. **手动模拟器验证**：启动 app，走一遍核心流程。
6. **记录不稳定测试**：绿红不定的测试单独标记，开不稳定问题单。
7. **输出 QA 报告**：
   - 哪些 REQ 被验证
   - 哪些失败
   - `/browser-verify` 结果摘要
   - 不稳定测试列表
   - 建议下一步（`/signoff --stage=feel` / 回 BUILD / 回 REQ / 对失败创建 `/file-bug`）

当 E2E 或单元测试出现**连续失败**时，QA 报告应明确建议："该失败可能是一个 code-defect，建议调用 `/file-bug` 登记并分类。"不自动创建 bug 工件。

## QA 报告模板

```markdown
# QA 报告 — <story-id>

## 单元测试
- 结果：PASS / FAIL
- 命令输出：...

## E2E/UITests
- 结果：PASS / FAIL
- 命令：`npx playwright test`（或项目约定命令）
- 失败详情：...
- Playwright 产物：
  - trace 路径：...
  - screenshot 路径：...
- flaky 测试列表：...

## 运行时浏览器验证
- 状态：PASS / WARN / FAIL / SKIPPED / BLOCKED
- 报告：`.aiassist/stories/<id>/browser-verify-report.md`
- 关键发现摘要：...

## Coverage
- 行覆盖率：X%
- 阈值：Y%
- 结果：PASS / FAIL
- 未覆盖 seams：...

## 手动验证
- 环境：iPhone 17 Simulator, iOS 26
- 结果：...
- 截图：...

## 不稳定测试
| 测试名 | 现象 | 处理 |
|---|---|---|
| ... | 时绿时红 | 已开单，限时修 |

## 结论
- [ ] 可进入 `/signoff --stage=feel`
- [ ] 需回 BUILD
- [ ] 需回 REQ
```

## Playwright CI 模板

当项目需要把 Playwright E2E 接入 CI 时，使用以下 GitHub Actions 模板：

```yaml
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
          cache: 'npm'
      - run: npm ci
      - name: Install Playwright
        run: npx playwright install --with-deps chromium
      - name: Build
        run: npm run build
      - name: Run E2E tests
        run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

要点：
- CI 中安装浏览器二进制：`npx playwright install --with-deps chromium`。
- E2E 前先 build，确保测试跑在最新产物上。
- 失败时上传 `playwright-report/`（含 trace、screenshot、HTML 报告）。
- 质量门顺序：Lint → Type Check → Unit Tests → Build → Integration → E2E（可选）→ Security Audit。

## Playwright 重试与不稳定测试处理

- `playwright.config.ts` 中建议 CI 环境 `retries: 2`，本地 `retries: 0`。
- `/qa-runner` 对 Playwright 结果分类：
  - **连续失败**：同一测试在所有 retry 中失败 → 标记为 blocker，不建议进入 feel-signoff。
  - **Retry 后通过**：同一测试首次失败、retry 后通过 → 标记为 flaky，建议开 issue 跟踪，但可配置是否阻断。
  - **全部通过**：无需特殊处理。
- 不自动修改 E2E 测试来消除 flaky；疑似产品竞态或测试隔离问题则回流到 `/signoff --stage=assertion` 或 REQ。

## 纪律

- 行为对错由测试判；观感好坏留给 `/signoff --stage=feel` 人判。
- 不稳定测试不掩盖：默认放行但开限时单；反复时绿时红到阈值转阻断。
- 不自动修不稳定 E2E；疑似产品竞态则回 `/signoff --stage=assertion`/REQ。

## 与参考项目的差异

- gstack `qa` 强调健康分和差异感知测试；我们采用更轻量的报告模板。
- superpowers 给我们专家子代理审查模式，可扩展为并行 QA。

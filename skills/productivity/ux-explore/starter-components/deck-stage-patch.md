# deck-stage.js 本地补丁

`deck-stage.js` 在 Claude Design 每次升级时会被整体覆盖。本文件记录我们在其上方叠加的本地补丁，以便每次升级后重新应用。

每次升级流程：
1. 用新的上游版本覆盖 `deck-stage.js`。
2. 按下面的补丁重新应用，通过“锚点”字符串定位（这样即使上游行号变化也能工作）。
3. 运行 `node --check deck-stage.js` 确认无语法错误。

---

## 补丁 1：原生全屏自动隐藏缩略图轨道

**动机**：组件只在宿主通过 `postMessage({__omelette_presenting:true})` 进入演示模式时隐藏轨道，**不会**监听浏览器原生全屏。因此当 deck 独立部署，或通过 F11 / `element.requestFullscreen()` 进入全屏时，轨道不会自动隐藏。

**做法**：新增一个独立的 `_fullscreen` 标志，并监听 `fullscreenchange`。使用独立标志而不是复用 `_presenting`，以免覆盖宿主的演示模式消息（两条路径可共存）。

共四处修改。

### 1.1 `connectedCallback` — 注册 fullscreenchange 监听器

**锚点**（紧跟在 beforeprint/afterprint 注册之后）：

```js
      window.addEventListener('beforeprint', this._onBeforePrint);
      window.addEventListener('afterprint', this._onAfterPrint);
```

**在其后插入**：

```js
      // Native browser fullscreen (F11 / element.requestFullscreen) hides the
      // rail the same way host-driven presenting does. Independent flag so it
      // doesn't clobber _presenting when both paths are in play.
      this._onFsChange = () => {
        this._fullscreen = !!document.fullscreenElement;
        this._syncRailHidden();
        this._fit();
        this._scaleThumbs();
      };
      document.addEventListener('fullscreenchange', this._onFsChange);
```

### 1.2 `disconnectedCallback` — 解绑监听器

**锚点**：

```js
      window.removeEventListener('afterprint', this._onAfterPrint);
```

**在其后插入**：

```js
      if (this._onFsChange) document.removeEventListener('fullscreenchange', this._onFsChange);
```

### 1.3 `_railWidth()` — 全屏时返回 0（让画布填满）

**锚点 / 之前**：

```js
      if (!this._railEnabled || !this._railVisible || this.hasAttribute('no-rail')
          || this.hasAttribute('noscale') || this._presenting || this._previewMode
          || NARROW_MQ.matches) return 0;
```

**之后**（添加 `|| this._fullscreen`）：

```js
      if (!this._railEnabled || !this._railVisible || this.hasAttribute('no-rail')
          || this.hasAttribute('noscale') || this._presenting || this._previewMode
          || this._fullscreen || NARROW_MQ.matches) return 0;
```

### 1.4 `_syncRailHidden()` — 把全屏视为硬隐藏（display:none）

**锚点 / 之前**：

```js
      const hard = !this._railEnabled || this._presenting || this._previewMode;
```

**之后**（添加 `|| this._fullscreen`）：

```js
      const hard = !this._railEnabled || this._presenting || this._previewMode || this._fullscreen;
```

---

## 补丁 2：在覆盖工具栏添加全屏切换按钮 + `F` 快捷键

**动机**：给 deck 提供一键进入原生全屏演示的能力，并配上可发现的 `F` 快捷键，复用补丁 1 的轨道隐藏。（`requestFullscreen()` 需要用户手势 —— 按钮点击和按键都满足。）

**依赖补丁 1 — 先应用补丁 1。** 共七处修改。

### 2.1 `stylesheet` — 设置工具栏按钮及其 `F` 徽章样式

首先放宽 keycap 规则，使新按钮的徽章也有样式。**之前**：

```css
    .btn.reset .kbd {
```

**之后**：

```css
    .btn .kbd {
```

然后添加全屏按钮规则。**锚点**（`.kbd` 规则的右大括号，紧接 `.count` 之前）：

```css
      border-radius: 4px;
    }

    .count {
```

**在两者之间插入 `.btn.fs` 规则**：

```css
      border-radius: 4px;
    }
    .btn.fs { padding: 0 8px; gap: 6px; }
    .btn.fs .fs-exit { display: none; }
    :host([data-fullscreen]) .btn.fs .fs-enter { display: none; }
    :host([data-fullscreen]) .btn.fs .fs-exit { display: block; }

    .count {
```

### 2.2 `_render` — 在覆盖层标记中添加按钮

**锚点**（Reset 按钮，即 `overlay.innerHTML` 的最后一行）：

```js
        <button class="btn reset" type="button" aria-label="Reset to first slide" title="Reset (R)">Reset<span class="kbd">R</span></button>
```

**在其后插入**（仍在模板字面量内）。两个 SVG 分别是进入（四角向外）和退出（四角向内）图标；2.1 的 CSS 会根据 `:host([data-fullscreen])` 只显示其中一个：

```js
        <button class="btn fs" type="button" aria-label="Enter fullscreen" title="Fullscreen (F)">
          <svg class="fs-enter" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 6V2h4M14 6V2h-4M2 10v4h4M14 10v4h-4"/></svg>
          <svg class="fs-exit" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 2v4H2M10 2v4h4M6 14v-4H2M10 14v-4h4"/></svg>
          <span class="kbd">F</span>
        </button>
```

### 2.3 `_render` — 绑定点击事件

**锚点**：

```js
      overlay.querySelector('.reset').addEventListener('click', () => this._go(0, 'click'));
```

**在其后插入**：

```js
      overlay.querySelector('.fs').addEventListener('click', () => this._toggleFullscreen());
```

### 2.4 `_render` — 保留按钮引用（用于反映状态的 aria-label）

**锚点**：

```js
      this._totalEl = overlay.querySelector('.total');
```

**在其后插入**：

```js
      this._fsBtn = overlay.querySelector('.fs');
```

### 2.5 添加 `_toggleFullscreen()` 方法

**锚点**（`_advance()` 的末尾）：

```js
      if (i < 0 || i >= this._slides.length) { this._flashOverlay(); return; }
      this._go(i, reason);
    }
```

**在那个右大括号之后插入**：

```js
    /** Toggle native fullscreen on the whole document. Must be called from a
     *  user gesture (button click or keydown) or requestFullscreen rejects.
     *  The fullscreenchange handler (Patch 1) hides the rail and swaps the
     *  button icon. Standard API only — F11 / webkit-prefixed flows are out
     *  of scope, matching Patch 1's listener. */
    _toggleFullscreen() {
      try {
        if (document.fullscreenElement) {
          if (document.exitFullscreen) document.exitFullscreen();
        } else if (document.documentElement.requestFullscreen) {
          const p = document.documentElement.requestFullscreen();
          if (p && p.catch) p.catch(() => {});
        }
      } catch (e) {}
    }
```

### 2.6 `_onKey` — 添加 `F` 快捷键

**锚点 / 之前**：

```js
      } else if (key === 'r' || key === 'R') {
        this._go(0, 'keyboard');
      } else if (/^[0-9]$/.test(key)) {
```

**之后**（插入 `f`/`F` 分支 —— 修饰键组合已经在前面退出，因此 `Cmd/Ctrl+F` 浏览器查找不受影响）：

```js
      } else if (key === 'r' || key === 'R') {
        this._go(0, 'keyboard');
      } else if (key === 'f' || key === 'F') {
        this._toggleFullscreen();
      } else if (/^[0-9]$/.test(key)) {
```

### 2.7 `_onFsChange` — 在宿主和按钮上反映状态（修正补丁 1.1）

**锚点**（补丁 1.1 处理函数的前两行）：

```js
      this._onFsChange = () => {
        this._fullscreen = !!document.fullscreenElement;
```

**在第二行之后立即插入**：

```js
        this.toggleAttribute('data-fullscreen', this._fullscreen);
        if (this._fsBtn) {
          this._fsBtn.setAttribute('aria-label', this._fullscreen ? 'Exit fullscreen' : 'Enter fullscreen');
          this._fsBtn.setAttribute('title', this._fullscreen ? 'Exit fullscreen (F)' : 'Fullscreen (F)');
        }
```

---

## 验证

- `node --check deck-stage.js` 通过。
- 在浏览器中打开任意 deck，通过 **Fullscreen API** 进入全屏 —— 例如从用户手势（按钮/按键）调用 `document.documentElement.requestFullscreen()`。轨道及其右侧调整大小把手都应消失（`.rail[data-presenting]{display:none}` 加上隐藏把手的相邻兄弟选择器），画布会重新适配以填满视口；退出全屏则恢复轨道。
  - 注意：浏览器自身的 F11 全屏**不会**触发 `fullscreenchange` 或设置 `document.fullscreenElement`，因此不会隐藏轨道 —— 只有 Fullscreen API 会。这与“演示”按钮（调用 `requestFullscreen()`）的行为一致。
  - 无需真实手势快速检查：在 devtools 中执行 `const d = document.querySelector('deck-stage'); d._fullscreen = true; d._syncRailHidden(); d._fit(); d._scaleThumbs();` 应隐藏轨道；设 `d._fullscreen = false` 再重新执行即可恢复。
- 宿主演示模式（`__omelette_presenting`）不受影响 —— 两个标志相互独立。
- 补丁 2：按 `F`（或点击覆盖工具栏中的 ⛶ 按钮）—— deck 进入全屏，轨道隐藏（补丁 1），按钮切换为退出图标并显示 “Exit fullscreen” 标签；再按 `F` / 点击，或按 Esc，退出并恢复一切。`Cmd/Ctrl+F` 仍会打开浏览器查找（修饰键组合在 `_onKey` 中已提前退出）。

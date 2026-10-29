# Changelog

## 1.0.1 — 2026-10-29

- 修复合盖、外接屏及屏幕布局切换后的悬浮球错位，按显示器保存相对位置。
- 悬浮球层级与 LiteTick、LitePark 对齐，拖动经过 Dock 时保持可见。
- 拖动时允许进入 Dock 区域，松手后再校正边界，与其他 Lite 应用一致。
- Preserve display-relative floating-ball positions across clamshell and monitor-layout changes. Keep the floating ball above the Dock. Apply visible-screen bounds on mouse release instead of during dragging.

## 1.0.0 — 2026-10-28

首个公开版本 / Initial public release.

- 原生 SwiftUI + AppKit 悬浮计算器，朱红色极简算盘 Logo。
- 48pt 悬浮球、拖动、可见区域限制和位置恢复。
- 悬停预览，点击面板固定并取得键盘焦点。
- 鼠标与键盘四则运算，Decimal 十进制计算、小数、退格、清除、除零及越界恢复。
- 关闭按钮、Esc、外部点击收起；悬浮球右键菜单退出。
- 完全离线，仅保存悬浮球位置。

Apple silicon binary, macOS 13+ deployment target, Simplified Chinese UI messages. Ad-hoc signed; not notarized.

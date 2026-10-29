# LiteNum 1.0.1

- 修复合盖、外接屏及屏幕布局切换后的悬浮球错位，按显示器保存相对位置。
- 悬浮球层级与 LiteTick、LitePark 对齐，拖动经过 Dock 时保持可见。
- 拖动时允许进入 Dock 区域，松手后再校正边界，与其他 Lite 应用一致。

Preserve display-relative floating-ball positions across clamshell and monitor-layout changes. Keep the floating ball above the Dock. Apply visible-screen bounds on mouse release instead of during dragging.

Apple silicon / macOS. Includes the app ZIP, SHA-256 checksum and release manifest.

本次沿用已交付的本机修复，仅检查编译、签名、版本和发布包一致性；未增加自动化或交互测试。

# LiteNum 1.0.0 — 轻巧、简洁、随时可算

LiteNum 的首个公开版本：原生 macOS 悬浮计算器，本地离线，专注基础四则运算。

<img src="https://raw.githubusercontent.com/victor-zhang-2026/LiteNum/v1.0.0/docs/images/calculator.png" width="280" alt="LiteNum：128 × 0.8 = 102.4">

## 下载 / Download

**Apple 芯片 Mac：下载 `LiteNum-1.0.0-macOS-arm64.zip`，解压后拖入「应用程序」。** GitHub 的 Source code 下载项为源码。

部署目标 macOS 13+；实际测试 macOS 27.0.1。界面提示为简体中文。当前包使用 ad-hoc 本地签名，未经过 Developer ID 签名或 Apple 公证。

Apple silicon binary; macOS 13+ deployment target. Tested on macOS 27.0.1. Simplified Chinese UI messages. Ad-hoc signed and not notarized.

## 使用

- 鼠标移入悬浮球展开预览，未点击面板时移出自动收起。
- 点击面板后直接键盘输入，也可点击计算按钮；移开鼠标仍保持打开。
- 点击面板和悬浮球之外、点击叉或按 Esc 收起；悬浮球继续常驻。
- 拖动悬浮球调整位置，下次启动恢复。
- 右键悬浮球仅提供“退出 LiteNum”。

支持加减乘除、小数、清除和退格。采用逐步运算：`2 + 3 × 4 = 20`。Decimal 计算支持 `0.1 + 0.2 = 0.3`，结果保留 16 位有效数字。

Hover to preview, click the panel to type, and dismiss with an outside click, close button or Esc. Drag the ball to move it. Keyboard and mouse input, sequential decimal arithmetic, saved position, fully offline.

## 安装与验证

已有 LiteNum 运行时，先右键退出，再替换 App。核对下方校验值；首次打开可能需要在系统隐私与安全性设置中确认。

20 组测试、103 条断言通过；实际验证了键盘计算、外部点击收起和其他应用键盘输入隔离。实体双屏、全屏 Spaces 与旧版 macOS 尚未实测。详情见附件 `MANIFEST.md`。

```text
c56944e313224ec30fce96dc61361d68a5319eed116ce5bea4802860799ee08c  LiteNum-1.0.0-macOS-arm64.zip
```

[使用说明](https://github.com/victor-zhang-2026/LiteNum#readme) · [反馈问题](https://github.com/victor-zhang-2026/LiteNum/issues)

# LiteNum 1.0.0 release manifest

- Date: 2026-10-28
- Version: 1.0.0; build: 1
- Bundle ID: com.victor.litenum
- Artifact: LiteNum-1.0.0-macOS-arm64.zip
- Architecture: arm64 (Apple silicon)
- Deployment target: macOS 13.0
- UI messages: Simplified Chinese
- Signing: ad-hoc; no Developer ID signature or Apple notarization
- License: MIT
- SHA-256: c56944e313224ec30fce96dc61361d68a5319eed116ce5bea4802860799ee08c

## Validation

The accepted local build 1 is published unchanged. App ZIP bytes match the delivered local package; only the filename differs.

- 20 test cases, 103 assertions passed: arithmetic, decimal precision, sequential evaluation, operator replacement, input limits, result continuation, backspace, error recovery, scientific notation, overflow and keyboard mapping.
- Geometry tests cover 48pt ball placement, saved-display selection, pointer selection, removed displays, negative origins, vertically arranged screens, screen edges and panel spacing.
- Native checks confirmed clicking the panel then typing `128*0.8` gives `102.4`; decimal input gives `0.3` for `0.1+0.2`; mouse input, zero-division recovery, Backspace, Delete and Esc were checked.
- Final native checks confirmed the one-item Quit menu, click-outside dismissal, and keyboard isolation: Apple's Calculator received `12+3` and displayed `15` while LiteNum stayed collapsed.
- App version, executable architecture, strict code-sign verification and local ZIP extraction were verified.
- Product screenshots are real app captures with sample calculations.

## Evidence boundaries

Test environment: Apple silicon, macOS 27.0.1, Swift 6.4, macOS 27.0 SDK. One display at 1280×720 logical resolution.

Physical multi-display dragging, display hot-plugging, full-screen Spaces and older macOS versions have not been tested. Pure hover trajectories, fast crossing of the ball-to-panel gap and continuous pointer dragging were not independently and consistently replayed by the automation tool; the user accepted the running app's overall design and interaction. Geometry assertions do not replace physical multi-display testing.

Command Line Tools on the build machine lacks XCTest. The provided standalone Swift test runner executed the same test cases successfully. Build logs contain optional framework search-directory warnings; building, running and code-sign verification succeeded.

No Intel/Windows binary, scientific mode, calculation history, cloud service or automatic login launch is included.

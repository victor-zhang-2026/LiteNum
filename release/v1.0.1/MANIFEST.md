# LiteNum 1.0.1

- Date: 2026-10-29
- Version: 1.0.1
- Build: 3
- Bundle ID: com.victor.litenum
- Architecture: arm64
- Minimum macOS: 13.0
- Artifact: LiteNum-1.0.1-macOS-arm64.zip
- SHA-256: 2a182d8a103c4e3399066f6fcb8bbd2bac1fddff346b55977e5f6763ef3c1986
- Signing: ad-hoc; not Apple-notarized.

## Changes

Preserve display-relative floating-ball positions across clamshell and monitor-layout changes. Keep the floating ball above the Dock. Apply visible-screen bounds on mouse release instead of during dragging.

## Validation

Compilation and strict bundle-signature verification passed. The packaged executable matches the installed application. No additional automated or native interaction tests were run for this patch; physical display and mouse acceptance remained user-operated.

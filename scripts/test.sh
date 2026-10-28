#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
mkdir -p build/tests
sdk="${LITENUM_MACOS_SDK:-$(xcrun --show-sdk-path)}"
swiftc -sdk "$sdk" -D STANDALONE_TESTS Sources/LiteNumCore/*.swift Tests/LiteNumCoreTests/*.swift scripts/TestHarness.swift -o build/tests/LiteNumTests
build/tests/LiteNumTests

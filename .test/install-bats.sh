#!/usr/bin/env bash

# Wrapper script to download and install bats and its libs. Default installation
# path is configured for /usr/local

set -eou pipefail

if [[ "$(id -u)" != "0" ]]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

PREFIX="/usr/local"
BATS_INSTALL_DIR="/tmp/bats-core"
BATS_SUPPORT_INSTALL_DIR="/tmp/bats-support"
BATS_ASSERT_INSTALL_DIR="/tmp/bats-assert"
BATS_FILE_INSTALL_DIR="/tmp/bats-file"

echo "Installing bats and libraries"

# bats
if [[ ! -d "$BATS_INSTALL_DIR" ]]; then
    git clone --quiet --depth 1 https://github.com/bats-core/bats-core.git "$BATS_INSTALL_DIR" || true
fi

"$BATS_INSTALL_DIR/install.sh" "$PREFIX"

# bats-support
if [[ ! -d "$BATS_SUPPORT_INSTALL_DIR" ]]; then
    git clone --quiet --depth 1 https://github.com/bats-core/bats-support.git "$BATS_SUPPORT_INSTALL_DIR" || true
fi

echo "Copying bats-support"
install -d -m 755 "$PREFIX/bin/bats-support/src"
install -m 755 "$BATS_SUPPORT_INSTALL_DIR/src"/* "$PREFIX/bin/bats-support/src"
install -m 755 "$BATS_SUPPORT_INSTALL_DIR/load.bash" "$PREFIX/bin/bats-support"

# bats-assert
if [[ ! -d "$BATS_ASSERT_INSTALL_DIR" ]]; then
    git clone --quiet --depth 1 https://github.com/bats-core/bats-assert.git "$BATS_ASSERT_INSTALL_DIR" || true
fi

echo "Copying bats-assert"
install -d -m 755 "$PREFIX/bin/bats-assert/src"
install -m 755 "$BATS_ASSERT_INSTALL_DIR/src"/* "$PREFIX/bin/bats-assert/src"
install -m 755 "$BATS_ASSERT_INSTALL_DIR/load.bash" "$PREFIX/bin/bats-assert"

# bats-file
if [[ ! -d "$BATS_FILE_INSTALL_DIR" ]]; then
    git clone --quiet --depth 1 https://github.com/bats-core/bats-file.git "$BATS_FILE_INSTALL_DIR" || true
fi

echo "Copying bats-files"
install -d -m 755 "$PREFIX/bin/bats-file/src"
install -m 755 "$BATS_FILE_INSTALL_DIR/src"/* "$PREFIX/bin/bats-file/src"
install -m 755 "$BATS_FILE_INSTALL_DIR/load.bash" "$PREFIX/bin/bats-file"

echo "Cleaning up"
rm -rf "$BATS_INSTALL_DIR" "$BATS_SUPPORT_INSTALL_DIR" "$BATS_ASSERT_INSTALL_DIR" "$BATS_FILE_INSTALL_DIR"

#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PLIST="$SCRIPT_DIR/Packaging/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST")
PACKAGE_VERSION=$(print -r -- "$VERSION" | sed -E 's/[^0-9.]+/./g; s/\.+/./g; s/^\.//; s/\.$//')
PAYLOAD_ROOT="$SCRIPT_DIR/dist/pkg-root"
UNSIGNED_PKG="$SCRIPT_DIR/dist/vRemoter-$VERSION-unsigned.pkg"
FINAL_PKG="$SCRIPT_DIR/dist/vRemoter-$VERSION.pkg"
COMPONENTS="$SCRIPT_DIR/dist/pkg-components.plist"

"$SCRIPT_DIR/package-app.sh"
"$SCRIPT_DIR/Driver/build-driver.sh"

rm -rf "$PAYLOAD_ROOT" "$UNSIGNED_PKG" "$FINAL_PKG"
mkdir -p "$PAYLOAD_ROOT/Applications"
mkdir -p "$PAYLOAD_ROOT/Library/Audio/Plug-Ins/HAL"

ditto "$SCRIPT_DIR/dist/build/vRemote.app" "$PAYLOAD_ROOT/Applications/vRemote.app"
ditto "$SCRIPT_DIR/Driver/build/vRemoteDriver.driver" \
  "$PAYLOAD_ROOT/Library/Audio/Plug-Ins/HAL/vRemoteDriver.driver"

pkgbuild --analyze --root "$PAYLOAD_ROOT" "$COMPONENTS"
# Always install at the payload paths, even when another copy of the app exists.
perl -0777 -pi -e 's/(<key>BundleIsRelocatable<\/key>\s*)<true\/>/${1}<false\/>/g' "$COMPONENTS"

pkgbuild \
  --root "$PAYLOAD_ROOT" \
  --component-plist "$COMPONENTS" \
  --install-location / \
  --ownership recommended \
  --scripts "$SCRIPT_DIR/Packaging/pkg-scripts" \
  --identifier "local.simaqingfeng.vRemoter.pkg" \
  --version "$PACKAGE_VERSION" \
  "$UNSIGNED_PKG"

if [[ -n "${INSTALLER_SIGN_IDENTITY:-}" ]]; then
  productsign \
    --sign "$INSTALLER_SIGN_IDENTITY" \
    "$UNSIGNED_PKG" \
    "$FINAL_PKG"
  rm -f "$UNSIGNED_PKG"
else
  mv "$UNSIGNED_PKG" "$FINAL_PKG"
  print -u2 "Warning: INSTALLER_SIGN_IDENTITY is not set; package is unsigned."
fi

pkgutil --check-signature "$FINAL_PKG" || true
cp "$SCRIPT_DIR/Driver/build/vRemoteDriver-source.tar.gz" \
  "$SCRIPT_DIR/dist/vRemoteDriver-0.5.0-vremote.1-source.tar.gz"
print "Built: $FINAL_PKG"

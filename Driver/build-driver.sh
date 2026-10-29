#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
BUILD_DIR="$SCRIPT_DIR/build"
SOURCE_DIR="$BUILD_DIR/driver-source"
OUTPUT_DRIVER="$BUILD_DIR/vRemoteDriver.driver"
CACHE_DIR="$SCRIPT_DIR/../.build/driver-source"
ARCHIVE="$CACHE_DIR/BlackHole-v0.5.0.tar.gz"
SOURCE_SHA256="8d79b803ee5c2c0919c6718d76adbbfbcaa1abb82b42b0b3c1fbbf5fe0d344d9"

mkdir -p "$CACHE_DIR"
if [[ ! -f "$ARCHIVE" ]]; then
  curl --fail --location --silent --show-error \
    "https://codeload.github.com/ExistentialAudio/BlackHole/tar.gz/refs/tags/v0.5.0" \
    -o "$ARCHIVE"
fi
print -r -- "$SOURCE_SHA256  $ARCHIVE" | shasum -a 256 -c -

rm -rf "$BUILD_DIR"
mkdir -p "$SOURCE_DIR"
tar -xzf "$ARCHIVE" --strip-components=1 -C "$SOURCE_DIR"

# Keep the Box virtual; only the audio Device advertises USB transport.
perl -0777 -pi -e '
  s/\A/\/\* Modified for vRemoter on 2026-10-29: renamed Box and USB Device transport. \*\/\n/;
  s/BlackHole Box/vRemoteDr Box/g;
  my $count = s/(BlackHole_GetDevicePropertyData: not enough space for the return value of kAudioDevicePropertyTransportType for the device"\);\s*\*\(\(UInt32\*\)outData\) = )kAudioDeviceTransportTypeVirtual;/${1}kAudioDeviceTransportTypeUSB;/g;
  die "Expected exactly one device transport change\n" unless $count == 1;
' "$SOURCE_DIR/BlackHole/BlackHole.c"

cat > "$SOURCE_DIR/build.sh" <<'BUILD_SCRIPT'
#!/bin/zsh
set -euo pipefail
SOURCE_DIR="${0:A:h}"
OUTPUT_DRIVER="${1:-$SOURCE_DIR/../vRemoteDriver.driver}"
mkdir -p "$OUTPUT_DRIVER/Contents/MacOS" "$OUTPUT_DRIVER/Contents/Resources"
xcrun clang -bundle -O2 -std=gnu11 -fblocks \
  -arch arm64 -arch x86_64 -mmacosx-version-min=11.0 \
  '-DkDriver_Name="vRemoteDr"' \
  '-DkPlugIn_BundleID="audio.local.vRemoteDriver2chXX"' \
  -DkNumber_Of_Channels=2 \
  -framework CoreAudio -framework CoreFoundation -framework Accelerate \
  "$SOURCE_DIR/BlackHole/BlackHole.c" \
  -o "$OUTPUT_DRIVER/Contents/MacOS/BlackHole"
cp "$SOURCE_DIR/BlackHole/BlackHole.plist" "$OUTPUT_DRIVER/Contents/Info.plist"
cp "$SOURCE_DIR/BlackHole/BlackHole.icns" "$OUTPUT_DRIVER/Contents/Resources/BlackHole.icns"
cp "$SOURCE_DIR/LICENSE" "$OUTPUT_DRIVER/Contents/Resources/LICENSE"
cp "$SOURCE_DIR/SOURCE.md" "$OUTPUT_DRIVER/Contents/Resources/SOURCE.md"
PLIST="$OUTPUT_DRIVER/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable BlackHole" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier audio.local.vRemoteDriver2chXX" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleName vRemote Driver" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 0.5.0-vremote.1" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 596" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 11.0" "$PLIST"
/usr/libexec/PlistBuddy -c "Delete :CFPlugInFactories" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFPlugInFactories dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :CFPlugInFactories:B7C4C615-9E72-4C83-A329-71C4E50E4A91 string BlackHole_Create" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFPlugInTypes:443ABAB8-E7B3-491A-B985-BEB9187030DB:0 B7C4C615-9E72-4C83-A329-71C4E50E4A91" "$PLIST"
codesign --force --deep --sign - --timestamp=none "$OUTPUT_DRIVER"
codesign --verify --deep --strict "$OUTPUT_DRIVER"
BUILD_SCRIPT
chmod +x "$SOURCE_DIR/build.sh"
cat > "$SOURCE_DIR/SOURCE.md" <<'SOURCE_NOTICE'
# vRemote Driver source

Based on ExistentialAudio/BlackHole v0.5.0, commit
1dcceef64731f30f384b0683ce928f9e6c38153c.
Upstream: https://github.com/ExistentialAudio/BlackHole/tree/v0.5.0
Upstream archive SHA-256:
8d79b803ee5c2c0919c6718d76adbbfbcaa1abb82b42b0b3c1fbbf5fe0d344d9

Modified for vRemoter on 2026-10-29. The driver remains GPL v3;
see LICENSE for the full license and original copyright notice.

Changes: rename Box to vRemoteDr Box; advertise USB transport for the
Device while keeping the Box virtual; build two channels with the
vRemoteDr name, audio.local.vRemoteDriver2chXX bundle ID and the
B7C4C615-9E72-4C83-A329-71C4E50E4A91 factory UUID.
Device UID vRemoteDr2ch_UID and model UID vRemoteDr2ch_ModelUID are retained.

On macOS with Command Line Tools, run ./build.sh /absolute/output/vRemoteDriver.driver
from this extracted source directory. This works offline and requires no
installed BlackHole driver or third-party libraries. The output contains
arm64 and x86_64 slices and an ad-hoc signature. It does not install anything.
SOURCE_NOTICE

"$SOURCE_DIR/build.sh" "$OUTPUT_DRIVER"
tar -czf "$BUILD_DIR/vRemoteDriver-source.tar.gz" -C "$BUILD_DIR" driver-source
print "Built: $OUTPUT_DRIVER"
print "Architectures: $(lipo -archs "$OUTPUT_DRIVER/Contents/MacOS/BlackHole")"
print "Corresponding source: $BUILD_DIR/vRemoteDriver-source.tar.gz"

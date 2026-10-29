# vRemote Driver: source build

The audio HAL plug-in exposes `vRemoteDr 2ch` for vRemoter's mixed audio output.
It is a modified BlackHole driver, independently licensed under GPL v3.

## Build

On macOS with Command Line Tools:

```bash
./Driver/build-driver.sh
```

The builder downloads BlackHole **v0.5.0**, commit
`1dcceef64731f30f384b0683ce928f9e6c38153c`, from the official
[ExistentialAudio/BlackHole repository](https://github.com/ExistentialAudio/BlackHole/tree/v0.5.0).
It verifies the archive SHA-256 before extracting:

```text
8d79b803ee5c2c0919c6718d76adbbfbcaa1abb82b42b0b3c1fbbf5fe0d344d9
```

No preinstalled BlackHole driver or full Xcode installation is required.
The download is cached in `.build/driver-source/`; subsequent builds use the
verified cache. No driver is installed by the builder.

Outputs:

- `Driver/build/vRemoteDriver.driver`: ad-hoc signed arm64 + x86_64 HAL plug-in.
- `Driver/build/vRemoteDriver-source.tar.gz`: complete modified upstream source,
  GPL license, provenance, and an offline `build.sh`.

`build-pkg.sh` includes the driver in the PKG and copies the source archive to
`dist/vRemoteDriver-0.5.0-vremote.1-source.tar.gz`. Publish that archive beside
any installer containing this driver.

## Modifications

- Two audio channels and device name `vRemoteDr 2ch`.
- Bundle ID `audio.local.vRemoteDriver2chXX`.
- Factory UUID `B7C4C615-9E72-4C83-A329-71C4E50E4A91`.
- Device UID `vRemoteDr2ch_UID` and model UID `vRemoteDr2ch_ModelUID`.
- Box name `vRemoteDr Box`; Box transport remains virtual.
- Audio Device transport reports USB, matching the earlier vRemote driver.
  This allows input methods that filter out virtual transport devices to list it.

The source edits and compiler definitions replace the previous binary-patching
builder. The source version is the same tag shown by the previously installed
driver's bundle metadata; the new build's version is `0.5.0-vremote.1`.

## Offline rebuild

Extract the source archive, then run:

```bash
cd driver-source
./build.sh /absolute/output/vRemoteDriver.driver
```

The extracted archive contains all driver source, resources and build instructions;
no network access or installed BlackHole binary is used by this command.

## Installation and verification boundary

The full PKG installs to `/Library/Audio/Plug-Ins/HAL/` and restarts system audio.
Use the App-only DMG for routine updates when a working driver is already installed.
The source-built driver is checked for loadability, identifiers, transport type,
format and signing. Those checks do not replace a fresh-install and live audio test.

Run the process-local smoke test without installing the driver:

```bash
xcrun clang -Wall -Wextra SelfTests/driver-smoke.c \
  -framework CoreAudio -framework CoreFoundation -o .build/driver-smoke
.build/driver-smoke Driver/build/vRemoteDriver.driver/Contents/MacOS/BlackHole
```

`install-driver.sh` refuses to overwrite an existing copy. `uninstall-driver.sh`
removes only the vRemote driver. Both require administrator privileges.

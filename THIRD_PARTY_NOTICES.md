# Third-party notices

`vRemoter` contains code adapted from
[fanxeon/mi-ao](https://github.com/fanxeon/mi-ao), distributed under the MIT
License, Copyright (c) 2026 FanXeon@Poemcoder with Codex.

Its ATVV protocol and IMA/DVI ADPCM implementation were informed by:

- [b0o/ATVVoice](https://github.com/b0o/ATVVoice), MIT License,
  Copyright (c) 2026 Maddison Cohodas.
- [Google Voice over BLE specification v1.0](https://wangefan.github.io/linux_kernel_driver/resources/Google_Voice_over_BLE_spec_v1.0.pdf).

`vRemoteDriver.driver` is a modified build of
[ExistentialAudio/BlackHole](https://github.com/ExistentialAudio/BlackHole)
v0.5.0 (commit `1dcceef64731f30f384b0683ce928f9e6c38153c`) and remains licensed
under GNU GPL v3. `Driver/build-driver.sh` verifies the upstream source archive,
applies the vRemote name, identifiers and audio-device transport changes, and
compiles the driver with Apple's Command Line Tools. BlackHole's original
copyright and license are preserved. Releases containing the driver also include
the complete modified source and an offline build script in a separate source
archive; see `Driver/README.md` for details.

# vRemoter · 让遥控器成为你的 Mac 快捷键面板

**按一下说话，按一下执行。把常用操作，放到手边。**

[![macOS](https://img.shields.io/badge/platform-macOS-111111)](https://github.com/willorn/vRemoter)
[![MIT License](https://img.shields.io/badge/app-MIT-2ea44f)](LICENSE)
[![Fork](https://img.shields.io/badge/fork-VincentKingHsu%2FvRemoter-586069)](https://github.com/VincentKingHsu/vRemoter)

[下载与版本记录](https://github.com/willorn/vRemoter/releases) · [快速开始](#快速开始) · [选择安装包](#选择安装包) · [从源码构建](#从源码构建)

vRemoter 把蓝牙语音遥控器变成 macOS 的桌面控制器：用语音键启动输入，用其他按钮触发你自己的快捷键。写代码、改文档、翻页面，常用动作都可以交给手里的遥控器。

这是基于 [VincentKingHsu/vRemoter](https://github.com/VincentKingHsu/vRemoter) 的个人维护 fork，重点改进**任意组合键录制**与**输入法适配**。App 保留上游 MIT 许可证及作者署名，不属于上游官方发行版。

## 一个遥控器，多一种工作方式

| 想做的事 | vRemoter 怎么帮你 |
| --- | --- |
| 把想法说出来 | 用语音键控制输入法；Chromecast 支持短按切换、长按说话 |
| 给常用操作留一个实体按钮 | 为方向、确认、返回、YouTube、Netflix、音量等普通按钮录制按键或组合键 |
| 使用 `Control + Option + A` 这样的快捷键 | 普通按钮映射和语音触发键都支持录制自定义组合键 |
| 更换同型号遥控器 | 映射按型号保存，无需重新配置每一只设备 |
| 调整语音输入来源 | 通过 `vRemoteDr 2ch` 混合遥控器与 Mac 麦克风，并分别调整输入开关 |

例如，把 YouTube 键设为 `⌃⌥A`，把 Netflix 键设为 `⌘V`，把方向键留给页面导航。具体动作由接收快捷键的 App 决定，可以配合编辑器或系统中已有的快捷键使用。

<details>
<summary>查看界面参考</summary>

以下为上游 1.1.1 的界面截图，展示音频控制台和按键映射布局；此 fork 增加了自定义语音快捷键、输入法选择和普通按钮的独立录制入口。

![音频控制台：分别控制 Mac 与遥控器音频输入](docs/assets/screenshots/vremoter-audio-1.1.1.png)

![按键映射：按遥控器型号配置常用操作](docs/assets/screenshots/vremoter-mapping-chromecast-1.1.1.png)

</details>

## 此 fork 改进了什么

版本：**`1.1.3-local`**

- **普通按钮都能直接录制。** 每个可映射的普通按钮旁都有独立录制按钮；菜单中的「录制任意按键…」也能正确显示。
- **语音快捷键不再限于单个修饰键。** 支持录制 `Control + Option + 字母` 等组合，并提供独立的右 Option 选项。
- **录制更符合预期。** Command 组合键会交给录制窗口处理；Option 字母键按实际物理键显示，避免把 `⌥A` 显示成特殊字符。
- **微信输入法实验性接入。** 可选择微信或豆包作为录音状态监听目标，配合语音会话控制使用。

微信输入法的语音启动已在一台搭载微信输入法 3.0.0 的 Mac 上验证；遥控器混音输入、不同版本与不同配置下的行为仍需进一步验证，因此继续标记为实验功能。

## 快速开始

### 1. 安装并连接遥控器

按[安装包说明](#选择安装包)安装 App。首次使用遥控器音频输入时，还需要安装音频驱动。通过 macOS 蓝牙设置配对受支持的遥控器，再打开 vRemoter。

按 App 提示在系统设置中授予蓝牙、麦克风、辅助功能与输入监控权限。

### 2. 给普通按钮录制快捷键

1. 打开「按键映射」，选择遥控器型号并启用映射。
2. 点击目标按钮右侧的录制图标，或在菜单中选择「录制任意按键…」。
3. 按下希望使用的按键或组合键，点击「保存映射」。

例如，按下 `Control + Option + A`，保存后对应遥控器按钮就会发送 `⌃⌥A`。关闭「启用映射」可恢复设备原有行为。

### 3. 配置语音输入

1. 在「按键映射」中选择豆包或微信输入法。
2. 选择语音触发键，或使用「自定义组合键…」录制快捷键；此设置必须与输入法中的语音快捷键一致。
3. 要让输入法接收遥控器与 Mac 的混音，请让输入法使用 `vRemoteDr 2ch` 音频设备。

输入法选项用于确定要监听哪个程序的真实录音状态，以便同步开关遥控器音频。普通按钮发送快捷键不依赖这一选择。

能打开语音面板，不代表已经使用遥控器麦克风：如果输入法仍使用 Mac 内置麦克风，采集的就是 Mac 音频。

## 选择安装包

发布采用两种安装包，分别面向首次安装和日常更新：

| 安装包 | 包含什么 | 什么时候选 |
| --- | --- | --- |
| **DMG** | 仅包含 App，不安装或更新驱动 | 已安装音频驱动，日常更新 vRemoter |
| **PKG** | App + `vRemoteDriver.driver` 音频驱动 | 首次使用遥控器混音，或某个版本明确要求更新驱动 |

**已有驱动，优先使用 DMG。** 退出 vRemoter，打开磁盘映像，将 App 拖入「应用程序」并替换旧版，然后重新打开。DMG 不执行驱动安装流程；若旧版 App 的所有权或系统权限限制替换，Finder 仍可能要求管理员验证。

PKG 会将驱动安装到系统音频目录，需要管理员验证，安装脚本会重启系统音频服务。正在使用音频设备时，请安排好安装时机。

请以 [GitHub Releases](https://github.com/willorn/vRemoter/releases) 中每个版本实际列出的附件、架构和安装说明为准。本地构建使用 ad-hoc 签名，未完成 Developer ID 签名与 Apple 公证。

## 支持的设备与边界

| 设备 | 已接入的型号标识 |
| --- | --- |
| Google Chromecast Voice Remote | VID `0x18D1` / PID `0x9450` |
| X6-Remote | VID `0x1D5A` / PID `0xC081` |

- 语音键用于语音会话控制；其他可映射的普通按钮用于发送自定义按键。
- X6 的鼠标模式切换属于设备固件内部功能，不能独立重映射。
- macOS 保留的快捷键可能无法录制；Fn 的表现取决于设备和输入法配置。
- 自定义快捷键能否触发目标动作，取决于前台 App、快捷键冲突及相关系统权限。
- 音频驱动基于 BlackHole，按 GPL v3 单独授权；与 App 的 MIT 许可证分开，详见[第三方许可说明](THIRD_PARTY_NOTICES.md)。

## 从源码构建

在 macOS 上使用 Swift 与 Command Line Tools 构建。首次构建会通过 Swift Package Manager 获取项目依赖。

```bash
# 音频协议回归检查
./run-self-tests.sh

# 快捷键与语音会话回归检查
swift build -c debug
.build/debug/vRemote --voice-session-self-test

# 构建 App
./package-app.sh

# 仅更新 App 的 DMG
./build-dmg.sh

# 包含驱动的首次安装 PKG
./build-pkg.sh
```

App 输出到 `dist/build/vRemote.app`，DMG 与 PKG 输出到 `dist/`。PKG 构建会下载并校验固定版本的 BlackHole 源码，再编译音频驱动，无需预先安装 BlackHole；离线重建方法见 [Driver/README.md](Driver/README.md)。App 默认按构建机器的架构编译，请勿将单架构构建标记为通用包。

公开分发包含驱动的 PKG 时，还需提供驱动对应的源码与构建材料，或取得适用的商业授权；仅保留许可证文件不能替代这一要求。详见[构建与运维说明](OPERATIONS.md)。

## 上游、更新与致谢

感谢 [VincentKingHsu/vRemoter](https://github.com/VincentKingHsu/vRemoter) 提供原始项目，以及第三方项目对音频驱动、ATVV 协议和解码实现的贡献。原作者署名、许可证及第三方声明均予保留。

此 fork 的下载与版本记录以[本仓库 Releases](https://github.com/willorn/vRemoter/releases)为准。App 内的检查更新、购买与支持开发入口目前仍沿用上游配置，由上游维护；安装上游官方更新可能覆盖此 fork 的改动。

[上游仓库](https://github.com/VincentKingHsu/vRemoter) · [上游官网](https://vremoter.vincentstudio.org/) · [第三方许可](THIRD_PARTY_NOTICES.md) · [驱动说明](Driver/README.md) · [上游更新历史](CHANGELOG.md) · [构建与运维说明](OPERATIONS.md)

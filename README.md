# vRemoter · 遥控器，也是 Mac 快捷键面板

**常用操作放到实体按钮上，想输入时按下语音键。**

[下载 DMG / PKG](https://github.com/willorn/vRemoter/releases) · [更新日志](CHANGELOG.md)

vRemoter 把蓝牙语音遥控器变成 macOS 桌面控制器，支持 Chromecast Voice Remote 和 X6-Remote。
这是 [VincentKingHsu/vRemoter](https://github.com/VincentKingHsu/vRemoter) 的个人维护 fork。

## 能做什么

- **自定义快捷键。** 为方向、确认、返回、YouTube、Netflix、音量等可映射按钮录制单键或组合键，例如 `⌃⌥A`、`⌘V`。
- **拖动换位。** 将左侧手柄拖到另一按键行，交换两边的动作与已录制组合键。
- **录制时防抢占。** 录制窗口获得焦点时拦截全局按键，避免 Thor 等启动器触发；录制结束恢复，不修改启动器配置。需辅助功能权限。
- **一键语音。** 配置输入法的语音触发键；Chromecast 支持短按切换、长按说话。
- **双麦混音。** 通过 `vRemoteDr 2ch` 混合遥控器和 Mac 麦克风，可分别开关输入。
- **容易找回控制台。** 状态栏菜单可直接打开控制台，也可选择在 Dock 显示，点击 Dock 图标恢复窗口。
- **配置跟随型号。** 更换同型号遥控器后继续使用已有映射。

`1.1.4-local` 开发版移除了打赏、自动打赏弹窗和上游更新检查。已发布版本与安装包通过本仓库 Releases 获取。

## 安装

面向 **Apple Silicon（arm64）Mac**，按每个 Release 的说明选择安装包：

| 安装包 | 适用场景 |
| --- | --- |
| **DMG：仅 App** | 已有可用驱动，日常更新；退出旧版，拖入「应用程序」并替换 |
| **PKG：App + 音频驱动** | 首次使用遥控器混音，或明确需要更新驱动；需要管理员验证并重启系统音频服务 |

App 未完成 Apple 公证。DMG 不安装驱动，但旧版文件权限限制替换时，Finder 仍可能要求验证。新源码构建驱动尚未完成完整首装和真实音频验证，含驱动的包目前作为预发布提供。

## 使用

1. 在 macOS 蓝牙设置中配对遥控器，打开 vRemoter，按提示授予所需权限。
2. 打开「按键映射」，选择遥控器型号并启用映射。
3. 点击目标按钮旁的录制图标，按下组合键，再点击「保存映射」。

语音输入：选择微信或豆包，并将 vRemoter 的触发键设为与输入法相同的快捷键。要接收遥控器混音，输入法需使用 `vRemoteDr 2ch`；仅打开语音面板不代表已经使用遥控器麦克风。

Dock 默认显示，可在状态栏菜单或 App 菜单中切换「在 Dock 中显示」。关闭控制台窗口不会退出程序；点击 Dock 图标或菜单里的「打开前台控制台」即可恢复。

## 支持范围

- Chromecast Voice Remote：VID `0x18D1` / PID `0x9450`；X6-Remote：VID `0x1D5A` / PID `0xC081`。
- 微信输入法为实验支持：3.0.0 的语音启动已有单机验证，混音及其他配置仍需验证。
- 语音键用于语音会话控制；X6 鼠标模式切换属于固件功能，不能单独映射。
- macOS 保留快捷键、Fn 和目标 App 的快捷键冲突可能影响录制或触发。

## 开发与许可

```bash
./run-self-tests.sh
swift build -c debug
.build/debug/vRemote --voice-session-self-test
./package-app.sh
./build-dmg.sh
./build-pkg.sh
```

需要 macOS 与 Command Line Tools。构建包输出到 `dist/`；驱动构建方法及对应源码见 [Driver/README.md](Driver/README.md)。

App 保留上游作者署名，采用 [MIT](LICENSE) 许可证；BlackHole 派生音频驱动采用 GPL v3，完整修改源码随含驱动的 Release 提供。详见[第三方声明](THIRD_PARTY_NOTICES.md)。

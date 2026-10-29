import CoreGraphics
import Foundation

enum InputTriggerKey: String, CaseIterable, Identifiable {
    case option
    case command
    case control
    case shift
    case function
    case rightOption
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .option: "Option (⌥)"
        case .command: "Command (⌘)"
        case .control: "Control (⌃)"
        case .shift: "Shift (⇧)"
        case .function: "Fn / Globe"
        case .rightOption: "Right Option (⌥)"
        case .custom: AppStorage.customVoiceShortcut?.label ?? L10n.text("自定义组合键…", "Custom shortcut…")
        }
    }

    var keyCodes: Set<Int64> {
        switch self {
        case .option: [0x3A, 0x3D]
        case .command: [0x37, 0x36]
        case .control: [0x3B, 0x3E]
        case .shift: [0x38, 0x3C]
        case .function: [0x3F]
        case .rightOption: [0x3D]
        case .custom: AppStorage.customVoiceShortcut.map { [Int64($0.keyCode)] } ?? []
        }
    }

    var primaryKeyCode: CGKeyCode {
        CGKeyCode(keyCodes.min() ?? 0x3A)
    }

    var flag: CGEventFlags {
        switch self {
        case .option: .maskAlternate
        case .command: .maskCommand
        case .control: .maskControl
        case .shift: .maskShift
        case .function: .maskSecondaryFn
        case .rightOption: .maskAlternate
        case .custom: CGEventFlags(rawValue: AppStorage.customVoiceShortcut?.flags ?? 0)
        }
    }
}

enum Key {
    static var isCapturingShortcut = false
    /// Lets the event tap distinguish vRemoter-generated events from physical
    /// keyboards, Bluetooth buttons, and external remappers.
    static let syntheticMarker: Int64 = 0x4D_49_52_42 // "MIRB"

    static func triggerDown(_ trigger: InputTriggerKey = AppStorage.inputTriggerKey) {
        post(trigger: trigger, keyDown: true)
    }

    static func triggerUp(_ trigger: InputTriggerKey = AppStorage.inputTriggerKey) {
        post(trigger: trigger, keyDown: false)
    }

    /// A deliberate short modifier click for Doubao's toggle mode.
    static func triggerTap(
        _ trigger: InputTriggerKey = AppStorage.inputTriggerKey,
        completion: (() -> Void)? = nil
    ) {
        triggerDown(trigger)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            triggerUp(trigger)
            completion?()
        }
    }

    private static func post(trigger: InputTriggerKey, keyDown: Bool) {
        if trigger == .custom {
            AppStorage.customVoiceShortcut?.post(isDown: keyDown)
            return
        }
        let source = CGEventSource(stateID: .hidSystemState)
        guard let event = CGEvent(
            keyboardEventSource: source,
            virtualKey: trigger.primaryKeyCode,
            keyDown: keyDown
        ) else { return }
        if trigger == .rightOption { event.type = .flagsChanged }
        event.flags = keyDown ? trigger.flag : []
        if trigger == .rightOption, keyDown {
            event.flags = CGEventFlags(rawValue: event.flags.rawValue | 0x40)
        }
        event.setIntegerValueField(.eventSourceUserData, value: syntheticMarker)
        event.post(tap: .cghidEventTap)
        print(
            "[KEY] synthetic \(trigger.title) " +
            (keyDown ? "DOWN" : "UP")
        )
    }
}

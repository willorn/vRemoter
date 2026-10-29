import Foundation

enum VoiceInputMethod: String, CaseIterable, Identifiable {
    case doubao
    case weType

    var id: String { rawValue }
    var title: String {
        self == .doubao ? L10n.text("豆包", "Doubao") : L10n.text("微信输入法（实验）", "WeType (experimental)")
    }
    var bundleID: String {
        self == .doubao ? "com.bytedance.inputmethod.doubaoime" : "com.tencent.inputmethod.wetype"
    }
}

enum AppStorage {
    static let loggingEnabledKey = "loggingEnabled"
    static let recordingEnabledKey = "recordingEnabled"
    static let macInputEnabledKey = "macInputEnabled"
    static let remoteInputEnabledKey = "remoteInputEnabled"
    static let inputTriggerKeyKey = "inputTriggerKey"

    static let logsDirectory: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/vRemote", isDirectory: true)
    }()

    static let logFile = logsDirectory.appendingPathComponent("vRemote.log")

    static let applicationSupportDirectory: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/vRemote", isDirectory: true)
    }()

    static let recordingsDirectory: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "Library/Application Support/vRemote/Recordings",
                isDirectory: true
            )
    }()

    static func prepare() {
        UserDefaults.standard.register(defaults: [
            loggingEnabledKey: false,
            recordingEnabledKey: false,
            macInputEnabledKey: true,
            remoteInputEnabledKey: true,
            inputTriggerKeyKey: InputTriggerKey.option.rawValue,
        ])
        ensureDirectory(logsDirectory)
        ensureDirectory(applicationSupportDirectory)
        ensureDirectory(recordingsDirectory)

        // vRemote has its own storage namespace and never touches V1 data.
    }

    static var loggingEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: loggingEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: loggingEnabledKey) }
    }

    static var recordingEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: recordingEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: recordingEnabledKey) }
    }

    static var macInputEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: macInputEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: macInputEnabledKey) }
    }

    static var remoteInputEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: remoteInputEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: remoteInputEnabledKey) }
    }

    static var inputTriggerKey: InputTriggerKey {
        get {
            let raw = UserDefaults.standard.string(forKey: inputTriggerKeyKey)
            return InputTriggerKey(rawValue: raw ?? "") ?? .option
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: inputTriggerKeyKey)
        }
    }

    static var customVoiceShortcut: RemoteCustomShortcut? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "customVoiceShortcut") else { return nil }
            return try? JSONDecoder().decode(RemoteCustomShortcut.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: "customVoiceShortcut")
            } else {
                UserDefaults.standard.removeObject(forKey: "customVoiceShortcut")
            }
        }
    }

    static var voiceInputMethod: VoiceInputMethod {
        get { VoiceInputMethod(rawValue: UserDefaults.standard.string(forKey: "voiceInputMethod") ?? "") ?? .doubao }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "voiceInputMethod") }
    }

    static func ensureDirectory(_ url: URL) {
        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true
        )
    }

    static func byteSize(of url: URL) -> UInt64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }

        var total: UInt64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(
                forKeys: [.isRegularFileKey, .fileSizeKey]
            ), values.isRegularFile == true else { continue }
            total += UInt64(values.fileSize ?? 0)
        }
        return total
    }

    static func clearFiles(in directory: URL) {
        let fm = FileManager.default
        ensureDirectory(directory)
        guard let files = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return }
        for file in files {
            try? fm.removeItem(at: file)
        }
    }

    static func formattedSize(_ bytes: UInt64) -> String {
        ByteCountFormatter.string(
            fromByteCount: Int64(bytes),
            countStyle: .file
        )
    }
}

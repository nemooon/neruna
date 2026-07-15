import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let caffeinate = CaffeinateController()

    private static let presets: [(title: String, duration: TimeInterval)] = [
        ("15分", 15 * 60),
        ("30分", 30 * 60),
        ("1時間", 60 * 60),
        ("2時間", 120 * 60),
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        caffeinate.onStateChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateIcon()
            }
        }
        updateIcon()
    }

    func applicationWillTerminate(_ notification: Notification) {
        caffeinate.stop()
    }

    // MARK: - NSMenuDelegate

    // 開くたびに組み立て直すことで、残り時間表示を最新にする
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        let header = NSMenuItem(title: statusDescription(), action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())

        if caffeinate.isActive {
            menu.addItem(makeItem(title: "オフにする", action: #selector(turnOff)))
            menu.addItem(.separator())
        }

        let indefinite = makeItem(title: "無期限にオン", action: #selector(startIndefinite))
        indefinite.state = (caffeinate.isActive && caffeinate.endDate == nil) ? .on : .off
        menu.addItem(indefinite)

        for (index, preset) in Self.presets.enumerated() {
            let item = makeItem(title: preset.title, action: #selector(startPreset(_:)))
            item.tag = index
            menu.addItem(item)
        }

        menu.addItem(.separator())
        menu.addItem(makeLaunchAtLoginItem())

        menu.addItem(.separator())
        let quit = makeItem(title: "Nerunaを終了", action: #selector(quit))
        quit.keyEquivalent = "q"
        menu.addItem(quit)
    }

    // MARK: - Actions

    @objc private func startIndefinite() {
        caffeinate.start(duration: nil)
    }

    @objc private func startPreset(_ sender: NSMenuItem) {
        guard Self.presets.indices.contains(sender.tag) else { return }
        caffeinate.start(duration: Self.presets[sender.tag].duration)
    }

    @objc private func turnOff() {
        caffeinate.stop()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    @objc private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            NSLog("ログイン項目の切り替えに失敗: \(error)")
        }
        // ユーザーがシステム設定で一度拒否している場合は設定画面に誘導する
        if service.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    // MARK: - Helpers

    private func makeItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    // SMAppService は .app バンドルからの起動時のみ使える（swift run では不可）
    private func makeLaunchAtLoginItem() -> NSMenuItem {
        guard Bundle.main.bundleURL.pathExtension == "app" else {
            let item = NSMenuItem(title: "ログイン時に起動（.app起動時のみ）", action: nil, keyEquivalent: "")
            return item
        }
        let item = makeItem(title: "ログイン時に起動", action: #selector(toggleLaunchAtLogin))
        item.state = SMAppService.mainApp.status == .enabled ? .on : .off
        return item
    }

    private func statusDescription() -> String {
        guard caffeinate.isActive else {
            return "スリープ防止: オフ"
        }
        guard let endDate = caffeinate.endDate else {
            return "スリープ防止: オン（無期限）"
        }
        let remaining = max(0, endDate.timeIntervalSinceNow)
        return "スリープ防止: オン（残り \(format(remaining))）"
    }

    private func format(_ interval: TimeInterval) -> String {
        let minutes = Int(interval.rounded(.up)) / 60
        let hours = minutes / 60
        if hours > 0 {
            let rest = minutes % 60
            return rest > 0 ? "\(hours)時間\(rest)分" : "\(hours)時間"
        }
        return "\(max(1, minutes))分"
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        let active = caffeinate.isActive
        let symbolName = active ? "cup.and.saucer.fill" : "cup.and.saucer"
        let description = active ? "スリープ防止オン" : "スリープ防止オフ"
        button.image = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: description
        )
        button.appearsDisabled = !active
        button.toolTip = statusDescription()
    }
}

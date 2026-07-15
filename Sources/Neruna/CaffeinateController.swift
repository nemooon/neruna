import Foundation

/// /usr/bin/caffeinate をサブプロセスとして起動・停止するコントローラ。
/// -d: ディスプレイのスリープを防止, -i: システムのアイドルスリープを防止
final class CaffeinateController {
    private var process: Process?

    /// 時間指定で開始した場合の終了予定時刻。無期限なら nil。
    private(set) var endDate: Date?

    /// 状態が変わったときに呼ばれる（メインスレッド保証なし）
    var onStateChange: (() -> Void)?

    var isActive: Bool {
        process?.isRunning ?? false
    }

    /// duration が nil なら無期限、指定があれば caffeinate -t で自動終了
    func start(duration: TimeInterval?) {
        stop()

        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        var arguments = ["-di"]
        if let duration {
            arguments += ["-t", String(Int(duration))]
        }
        p.arguments = arguments
        p.terminationHandler = { [weak self] _ in
            guard let self else { return }
            self.process = nil
            self.endDate = nil
            self.onStateChange?()
        }

        do {
            try p.run()
        } catch {
            NSLog("caffeinate の起動に失敗: \(error)")
            return
        }

        process = p
        endDate = duration.map { Date().addingTimeInterval($0) }
        onStateChange?()
    }

    func stop() {
        guard let p = process else { return }
        p.terminationHandler = nil
        p.terminate()
        process = nil
        endDate = nil
        onStateChange?()
    }
}

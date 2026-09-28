import Foundation
import Combine

@MainActor
class TokenDataProvider: ObservableObject {
    @Published var current: Int = 0
    @Published var limit: Int = 200000
    @Published var percentage: Int = 0
    @Published var isRising: Bool = true
    @Published var modelName: String = "—"

    private var previousPercentage: Int = 0
    private var timer: Timer?
    private var fileMonitorSource: DispatchSourceFileSystemObject?

    let trendLobster = "🦞"

    var tokenDisplay: String {
        let currentK = current / 1000
        let limitK = limit / 1000
        return "\(currentK)k/\(limitK)k tokens"
    }

    func startPolling() {
        fetchData()
        setupFileMonitor()
        // Fallback poll every 10s in case file monitor misses events
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.fetchData()
            }
        }
    }

    private func setupFileMonitor() {
        let sessionsPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".openclaw/agents/main/sessions/sessions.json").path
        guard FileManager.default.fileExists(atPath: sessionsPath) else { return }

        let fd = open(sessionsPath, O_EVTONLY)
        guard fd >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .extend],
            queue: .global(qos: .utility)
        )
        source.setEventHandler { [weak self] in
            Task { @MainActor in
                self?.fetchData()
            }
        }
        source.setCancelHandler { close(fd) }
        source.resume()
        fileMonitorSource = source
    }

    func fetchData() {
        guard let result = getTokenUsage() else { return }

        previousPercentage = percentage
        current = result.current
        limit = result.limit
        percentage = result.percentage
        modelName = result.model

        if previousPercentage > 0 {
            isRising = percentage >= previousPercentage
        }
    }

    private func getTokenUsage() -> (current: Int, limit: Int, percentage: Int, model: String)? {
        // Was: read ~/.openclaw/agents/*/sessions/sessions.json directly. OpenClaw migrated
        // session state into a SQLite store (openclaw-agent.sqlite); that flat file no longer
        // exists, so this always silently returned nil and the widget froze on stale/default
        // numbers. The CLI is the stable interface to whatever storage is live underneath
        // (found Sep 28, same root cause as the matching bug in molty-meter).
        guard let json = runOpenClawSessionsJSON(),
              let sessionsArray = json["sessions"] as? [[String: Any]],
              let first = sessionsArray.first,
              let model = first["model"] as? String,
              let totalTokens = first["totalTokens"] as? Int,
              let contextTokens = first["contextTokens"] as? Int else {
            return nil
        }

        let percent = contextTokens > 0 ? Int(Double(totalTokens) / Double(contextTokens) * 100) : 0
        // The CLI already returns sessions sorted most-recently-updated first.
        return (totalTokens, contextTokens, percent, formatModelName(model))
    }

    /// Runs `openclaw sessions --json` and parses stdout. Uses the absolute Homebrew path
    /// since GUI/LaunchAgent-launched apps don't inherit an interactive shell's PATH.
    private func runOpenClawSessionsJSON() -> [String: Any]? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/openclaw")
        process.arguments = ["sessions", "--json"]

        let stdout = Pipe()
        process.standardOutput = stdout
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            return nil
        }
        // Read to EOF before waiting on exit — waiting first risks a deadlock if output
        // ever exceeds the pipe buffer (child blocks writing, parent blocks waiting).
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    private func formatModelName(_ raw: String) -> String {
        // "claude-opus-4-6" -> "Opus 4.6", "gpt-5.1" -> "GPT 5.1"
        var name = raw
        if name.hasPrefix("claude-") {
            name = String(name.dropFirst("claude-".count))
        }
        // Replace last hyphen before version number with a dot: "opus-4-6" -> "opus-4.6"
        if let lastHyphen = name.lastIndex(of: "-"),
           let digitAfter = name.index(lastHyphen, offsetBy: 1, limitedBy: name.endIndex),
           name[digitAfter].isNumber {
            name.replaceSubrange(lastHyphen...lastHyphen, with: ".")
        }
        // Replace remaining hyphens with spaces
        name = name.replacingOccurrences(of: "-", with: " ")
        // Capitalize first letter of each word
        return name.split(separator: " ").map { word in
            let upper = ["gpt", "o1", "o3"]
            if upper.contains(word.lowercased()) {
                return word.uppercased()
            }
            return word.prefix(1).uppercased() + word.dropFirst()
        }.joined(separator: " ")
    }
}

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
        let openclawDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".openclaw/agents")
        guard let agentDirs = try? FileManager.default.contentsOfDirectory(
            at: openclawDir, includingPropertiesForKeys: nil
        ) else { return nil }

        var best: (current: Int, limit: Int, percentage: Int, model: String, lastModified: Date)?

        for agentDir in agentDirs {
            let sessionsFile = agentDir.appendingPathComponent("sessions/sessions.json")
            guard let data = try? Data(contentsOf: sessionsFile),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                continue
            }

            for (_, value) in json {
                guard let sessionInfo = value as? [String: Any],
                      let model = sessionInfo["model"] as? String,
                      let totalTokens = sessionInfo["totalTokens"] as? Int,
                      let contextTokens = sessionInfo["contextTokens"] as? Int,
                      let sessionFile = sessionInfo["sessionFile"] as? String else {
                    continue
                }

                // Prefer modelOverride (user's chosen model), then last JSONL message, then default
                let actualModel = (sessionInfo["modelOverride"] as? String)
                    ?? lastModelFromJSONL(path: sessionFile)
                    ?? model

                let percent = contextTokens > 0 ? Int(Double(totalTokens) / Double(contextTokens) * 100) : 0

                // Pick most recently modified session
                let sessionURL = URL(fileURLWithPath: sessionFile)
                let modDate = (try? sessionURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast

                if best == nil || modDate > best!.lastModified {
                    best = (totalTokens, contextTokens, percent, formatModelName(actualModel), modDate)
                }
            }
        }

        guard let result = best else { return nil }
        return (result.current, result.limit, result.percentage, result.model)
    }

    /// Read the model name from the last assistant message in a session JSONL file.
    private func lastModelFromJSONL(path: String) -> String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let content = String(data: data, encoding: .utf8) else { return nil }

        var lastModel: String?
        for line in content.components(separatedBy: "\n") where !line.isEmpty {
            guard let lineData = line.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any] else {
                continue
            }
            if let message = obj["message"] as? [String: Any],
               let model = message["model"] as? String {
                lastModel = model
            }
        }
        return lastModel
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

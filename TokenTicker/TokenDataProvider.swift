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

    let trendLobster = "🦞"

    var tokenDisplay: String {
        let currentK = current / 1000
        let limitK = limit / 1000
        return "\(currentK)k/\(limitK)k tokens"
    }

    func startPolling() {
        fetchData()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.fetchData()
            }
        }
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
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["openclaw", "sessions"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Failed to run openclaw: \(error)")
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return nil }

        // Parse model name and "20k/200k (10%)" from sessions output
        // Format: "claude-opus-4-6 20k/200k (10%)"
        let pattern = "(\\S+)\\s+(\\d+)k/(\\d+)k \\((\\d+)%\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(output.startIndex..., in: output)
        if let match = regex.firstMatch(in: output, range: range) {
            guard let modelRange = Range(match.range(at: 1), in: output),
                  let currentRange = Range(match.range(at: 2), in: output),
                  let limitRange = Range(match.range(at: 3), in: output),
                  let percentRange = Range(match.range(at: 4), in: output),
                  let current = Int(output[currentRange]),
                  let limit = Int(output[limitRange]),
                  let percent = Int(output[percentRange]) else {
                return nil
            }

            let rawModel = String(output[modelRange])
            let displayName = formatModelName(rawModel)
            return (current * 1000, limit * 1000, percent, displayName)
        }
        return nil
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

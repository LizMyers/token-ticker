import Foundation
import Combine

@MainActor
class TokenDataProvider: ObservableObject {
    @Published var current: Int = 0
    @Published var limit: Int = 200000
    @Published var percentage: Int = 0
    @Published var isRising: Bool = true

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

        if previousPercentage > 0 {
            isRising = percentage >= previousPercentage
        }
    }

    private func getTokenUsage() -> (current: Int, limit: Int, percentage: Int)? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["openclaw", "session_status"]

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

        // Parse "Context: 55k/200k (27%)"
        let pattern = "Context: (\\d+)k/(\\d+)k \\((\\d+)%\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(output.startIndex..., in: output)
        if let match = regex.firstMatch(in: output, range: range) {
            guard let currentRange = Range(match.range(at: 1), in: output),
                  let limitRange = Range(match.range(at: 2), in: output),
                  let percentRange = Range(match.range(at: 3), in: output),
                  let current = Int(output[currentRange]),
                  let limit = Int(output[limitRange]),
                  let percent = Int(output[percentRange]) else { return nil }

            return (current * 1000, limit * 1000, percent)
        }
        return nil
    }
}

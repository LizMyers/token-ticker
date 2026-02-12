# Token Ticker 🦞

**Stop API surprises. See your token burn in real-time.**

A macOS desktop widget that monitors your AI API token usage at a glance — so you never get blindsided by a 100% balance again.

---

## Who This Is For

- **Developers** using OpenClaw on macOS
- **AI builders** juggling multiple API keys (Anthropic, OpenAI, etc.)
- Anyone who's ever had an API call fail because they ran out of tokens
- People who like beautiful, functional desktop tools

**You'll need:** macOS 13+ and [OpenClaw](https://openclaw.ai) installed.

---

## What It Does

Sits on your desktop and shows:
- 📊 Your current token usage (as a %)
- 🦞 A rotating lobster that moves when usage changes
- 💾 Exact tokens used / max available
- 🔄 Auto-refreshes every 60 seconds

### Screenshot

![Token Ticker Widget](screenshot.png)

**The widget displays:**
- Large percentage at top (your token usage %)
- Animated lobster (spins when usage changes)
- Model name (which API you're tracking)
- Token count in human-readable format (e.g., 168k/200k)

No browser tabs. No clicking through dashboards. Just glance at your desktop.

---

## Get It Running (3 Steps)

### 1. Prerequisites
Make sure you have macOS 13+ and OpenClaw installed:
```bash
openclaw --version
```

(No OpenClaw? [Get it here.](https://openclaw.ai))

### 2. Install Token Ticker

Clone or download this repo:
```bash
git clone https://github.com/[YOUR-USERNAME]/token-ticker.git
cd token-ticker
```

Build the release version:
```bash
swift build -c release
cp .build/release/TokenTicker /Applications/TokenTicker
```

### 3. Launch It

Press **Cmd+Space**, type `TokenTicker`, hit Enter.

Done! The widget appears on your desktop and starts monitoring your OpenClaw token usage.

---

## How It Works

**Data Source:** Token Ticker reads from OpenClaw's session manager:
```bash
openclaw sessions
# Returns: 168k/200k (84%)
```

**Refresh:** Updates every 60 seconds (configurable).

**That's it.** No API keys to enter. No configuration. It just works with your existing OpenClaw setup.

---

## Development

### Real-Time Edits

Want to tweak colors, fonts, or behavior? Use the dev workflow:

1. Install watchexec (one-time):
```bash
brew install watchexec
```

2. Start the watcher:
```bash
cd token-ticker
watchexec -r 'swift build && pkill -f TokenTicker; sleep 0.5; swift run TokenTicker'
```

3. Edit any `.swift` file and save.

The widget rebuilds and relaunches automatically. See your changes in seconds.

### Key Files

- `TokenTickerApp.swift` — Window setup + lifecycle
- `ContentView.swift` — UI layout (fonts, sizes, spacing)
- `TokenDataProvider.swift` — Data fetching from `openclaw sessions`

### Customization Examples

**Change refresh rate** (edit `TokenDataProvider.swift`):
```swift
timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) // 30 seconds instead of 60
```

**Resize the widget** (edit `TokenTickerApp.swift`):
```swift
contentRect: NSRect(x: 0, y: 0, width: 200, height: 200) // Make it bigger
```

**Change font size** (edit `ContentView.swift`):
```swift
.font(.system(size: 50, weight: .light)) // Bigger percentage
```

---

## Troubleshooting

**Widget shows 0% or "Failed to fetch":**
- Verify `openclaw sessions` works in terminal:
  ```bash
  openclaw sessions
  ```
- If it fails, start the OpenClaw gateway:
  ```bash
  openclaw gateway start
  ```

**Widget not appearing after launch:**
- Check the Applications folder:
  ```bash
  ls -la /Applications/TokenTicker
  ```
- Try launching from Spotlight again (Cmd+Space → TokenTicker)

**Want to uninstall?**
```bash
rm /Applications/TokenTicker
```

---

## What's Next

Future versions might include:
- [ ] Multi-API support (OpenAI, Google Cloud, AWS in one widget)
- [ ] Cost estimation ($X spent, $Y remaining)
- [ ] Usage history + graphs
- [ ] Alerts when hitting 90%+ usage
- [ ] Dark/light mode toggle

---

## Open Source

This is a **portfolio project** — built to solve a real problem and shipped with care.

Feel free to:
- Fork it and customize for your needs
- Submit PRs for improvements
- Use it as a template for your own macOS widgets

**Built with:** Swift 5.10+ | SwiftUI | macOS 13+  
**License:** MIT  
**Author:** Liz Myers

---

## Questions?

Found a bug? Have an idea? Open an issue or PR. Let's build together! 🚀

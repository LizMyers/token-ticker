# TokenTicker 🦞

![Token Ticker Widget](screenshot.png)

Monitor your Molty's API Useage at a Glance. All you need to do is install it where your ~/.openclaw folder lives.

## Install

```bash
git clone https://github.com/LizMyers/token-ticker.git
cd token-ticker
swift build -c release
cp .build/release/TokenTicker /Applications/
```

Launch with Spotlight: **Cmd+Space** → `TokenTicker`

**Requires:** macOS 13+ and [OpenClaw](https://openclaw.ai)

---

## How It Works

Reads from `openclaw sessions status` every 60 seconds. No API keys needed — it uses your existing setup.

---

## Make It Your Own

All visual tweaks live in `ContentView.swift`:

**Font size & weight:**
```swift
.font(.system(size: 42, weight: .light))  // percentage display
.font(.system(size: 13, weight: .medium)) // labels
```

**Spacing:**
```swift
.padding(.top, 23)
.padding(.bottom, 26)
.padding(.leading, 20)
```

**Widget size:**
```swift
.frame(width: 160, height: 160)
```

**Refresh interval** (in `TokenDataProvider.swift`):
```swift
Timer.scheduledTimer(withTimeInterval: 60, repeats: true)  // seconds
```

---

## Why TokenTicker?
If tokens are the new currency, then we want to monitor them. Upcoming version will include a stock watch list type interface where users can monitor several API keys or token balances at once. Think percentages with directional arrows indicating increasing v. decreasing funds in real time.

## License

MIT — Liz Myers

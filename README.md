# TokenTicker 🦞

![Token Ticker Widget](screenshot.png)

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![OpenClaw](https://img.shields.io/badge/Requires-OpenClaw-coral)
![License](https://img.shields.io/badge/License-MIT-green)

## Why TokenTicker?

Tokens are the new currency and it's handy to monitor them - just like a stock ticker! Speaking of which, future versions will offer an extended list view where you can monitor several API keys at once. Think percentages with directional indicators showing token balances rising or falling in real time. Watch this space.

## Features

- **Glanceable** — Large percentage, always visible on your desktop
- **Auto-refresh** — Polls every 60 seconds
- **Zero config** — Reads your existing OpenClaw session, no API keys to enter
- **Lightweight** — Native Swift, minimal footprint

## Install

```bash
git clone https://github.com/LizMyers/token-ticker.git
cd token-ticker
swift build -c release
cp .build/release/TokenTicker /Applications/
```

Launch with Spotlight: **Cmd+Space** → `TokenTicker`<br>
**IMPORTANT** — select the executable, not the folder

**Requires:** macOS 13+ and [OpenClaw](https://openclaw.ai)

## How It Works

```
TokenTicker          OpenClaw
┌──────────┐        ┌──────────────────┐
│  Widget  │──poll──│ sessions status  │
│  (60s)   │◀─usage─│ 168k/200k (84%)  │
└──────────┘        └──────────────────┘
```

Reads from `openclaw sessions status`. That's it.

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

## Credits

Built by [Liz Myers](https://github.com/LizMyers) & [Claude](https://claude.ai), for the [OpenClaw](https://openclaw.ai/) community.


## License

MIT

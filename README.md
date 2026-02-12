# TokenTicker 🦞

![Token Ticker Widget](screenshot.png)

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![OpenClaw](https://img.shields.io/badge/Requires-OpenClaw-coral)
![License](https://img.shields.io/badge/License-MIT-green)

## Genesis

I kept getting surprised by API limits mid-conversation. So I built a tiny desktop widget that sits in the corner and shows my token burn in real time. Now I see it coming before it hits.

Sharing it in case you want the same peace of mind for your [Moltbot](https://openclaw.ai/) 🦞.

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

## What's Next

Upcoming versions will offer an extended list view — monitor several API keys at once with directional indicators showing balances rising or falling in real time.

## Credits

Built by [Liz Myers](https://github.com/LizMyers) & [Claude](https://claude.ai), for the [OpenClaw](https://openclaw.ai/) community.

## License

MIT

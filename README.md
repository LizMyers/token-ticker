# Token Ticker 🦞

A tiny macOS desktop widget that shows your OpenClaw token usage at a glance.

## Screenshot

```
┌─────────────────────────┐
│  78%               🦞   │
│  178k/200k tokens       │
│                         │
│  Haiku-4-5              │
└─────────────────────────┘
```

## Build & Run

### Option 1: Swift Package Manager
```bash
cd token-ticker
swift build
swift run
```

### Option 2: Xcode
1. Open Xcode
2. File → New → Project → macOS → App
3. Replace generated files with contents from `TokenTicker/`
4. Build & Run (⌘R)

## Data Source

Pulls from `openclaw session_status`:
```
🧮 Tokens: 10 in / 478 out
📚 Context: 55k/200k (27%)
```

Widget parses the Context line and refreshes every 60 seconds.

## The Lobster

- 🦞 facing right → usage trending up
- 🦞 facing left → usage trending down

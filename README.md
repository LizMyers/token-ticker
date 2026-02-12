# Token Ticker 🦞

![Token Ticker Widget](screenshot.png)

A tiny macOS desktop widget that shows your OpenClaw token usage at a glance.

## Install

```bash
git clone https://github.com/LizMyers/token-ticker.git
cd token-ticker
swift build -c release
cp .build/release/TokenTicker /Applications/
```

Launch with Spotlight (Cmd+Space → TokenTicker).

## Requirements

- macOS 13+
- [OpenClaw](https://openclaw.ai) installed

## How it works

Reads from `openclaw sessions` and refreshes every 60 seconds. The lobster flips when usage goes up.

## License

MIT

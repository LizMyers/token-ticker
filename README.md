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

Token Ticker polls OpenClaw's session manager every 60 seconds:

```bash
openclaw sessions status
# Returns: 168k/200k (84%)
```

The widget parses the context line and displays:
- **Percentage** — large, at a glance
- **Lobster** — flips upside down when usage is rising
- **Model name** — which API you're tracking
- **Token count** — exact numbers (e.g., 168k/200k)

No API keys to configure. It just reads your existing OpenClaw session data.

## License

MIT

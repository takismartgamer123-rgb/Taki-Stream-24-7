# Taki Stream DZ 24/7

A 24/7 automated YouTube live streaming system that displays a dynamic Arabic/Algerian dashboard with real-time channel statistics, humorous DZ news ("اخبار DZ المضحكة"), and motivational quotes — streamed directly to YouTube via RTMP using ffmpeg.

## How It Works

The stream runs as a continuous Bash loop that:
1. Fetches YouTube channel stats (subscribers, views) every hour via the YouTube Data API
2. Rotates random humorous news and motivational quotes every 3 minutes
3. Renders everything as a live video overlay using `ffmpeg` drawtext/drawbox filters
4. Pushes the stream to YouTube Live via RTMP

## Running on Replit

Click **Run** to start the stream. The workflow runs `stream.sh` in the console.

### Required Secrets (set in Replit Secrets tab)

| Secret | Description |
|---|---|
| `YOUTUBE_STREAM_KEY` | Your YouTube live stream key |
| `YOUTUBE_API_KEY` | YouTube Data API v3 key |
| `YOUTUBE_CHANNEL_ID` | Your YouTube channel ID (e.g. `UCxxxxxxx`) |
| `LOGO_URL` | (Optional) Direct URL to your channel logo image |

### System Dependencies

The following are installed automatically via Nix:
- `ffmpeg` — video encoding and streaming
- `curl` — HTTP requests
- `jq` — JSON parsing
- `imagemagick` — logo resizing

## Project Layout

```
stream.sh                  # Main streaming script (run this)
.github/workflows/stream.yml  # Original GitHub Actions version
replit.md                  # This file
```

## Originally Designed For

This project was built to run on GitHub Actions (triggered by schedule or manually). The `stream.sh` script is a Replit-compatible port of the same logic.

## User Preferences

- Keep all stream content in Arabic/Algerian Darja (dialect)
- Subscriber goal target: 5,000
- Stream resolution: 1920x1080 @ 1fps (low-bitrate, static dashboard style)

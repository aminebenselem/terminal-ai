# Terminal AI

An intelligent terminal assistant that suggests shell commands from natural language input. Minimal setup: Go CLI + Zsh/Bash adapters + optional Docker. No Kubernetes, Terraform, or ELK.

## Features

- Intelligent suggestions: type a request, get a shell command
- Zsh/Bash adapters: trigger suggestions inline (Ctrl+Space by default)
- Go CLI engine: calls Gemini API with context
- Robust fallback: never hangs; offline mode available
- Docker support: build and run a containerized backend binary

## Project Structure

```
terminal-ai/
├── adapters/            # Shell integrations
│   ├── adapter.zsh      # Zsh widget + keybinding
│   ├── adapter.bash     # Bash binding
│   └── adapter.posix    # POSIX fallback
├── ai-core/             # Go engine (CLI)
│   ├── engine.go        # Suggestion logic + Gemini call
│   └── go.mod           # Module config
├── cli/
│   └── terminal-ai      # Shell-executable launcher
├── devops/
│   └── docker/
│       └── backend.Dockerfile
├── install.sh           # Build + install helper
├── Makefile             # Build/test/docker targets
└── README.md
```

## Requirements

- Go 1.21+
- `jq` (adapter JSON parsing)
- Zsh or Bash
- Optional: Docker

## Install

```bash
# Prereqs
which jq || sudo apt-get update && sudo apt-get install -y jq

# Build and install
make build
make install
```

## Configure

Set your Gemini API key and optional tuning flags.

```bash
export GEMINI_API_KEY="your-api-key"
# Optional: tweak behavior
export TERMINAL_AI_TIMEOUT=5   # seconds, default 5
export TERMINAL_AI_DEBUG=1     # print debug info to stderr
export TERMINAL_AI_OFFLINE=0   # set to 1 to skip network calls
```

## Usage

- Direct CLI:
```bash
terminal-ai "list all files"
TERMINAL_AI_JSON=1 terminal-ai "find large files" | jq .
```

- Zsh adapter:
```bash
# If not auto-added by install.sh
source adapters/adapter.zsh
# Type a partial request then press Ctrl+Space
```

- Bash adapter:
```bash
# If not auto-added by install.sh
source adapters/adapter.bash
# Type a partial request then press Ctrl+Space
```

## Docker

```bash
# Build image
make docker-build

# Run container locally
make docker-run

# View logs / stop
make docker-logs
make docker-stop
```

## Troubleshooting

- Key not set:
       - Ensure `GEMINI_API_KEY` is exported in the same shell session.
       - Verify: `env | grep GEMINI_API_KEY`.

- Hanging / long wait:
       - The engine uses an HTTP timeout (default 5s). Adjust via `TERMINAL_AI_TIMEOUT`.
       - Force offline mode: `export TERMINAL_AI_OFFLINE=1` (echoes input as suggestion).

- 429 quota errors:
       - Check usage and billing for the project tied to your key.
       - Try again after the suggested retry delay or use offline mode.

- Adapter shows nothing:
       - Confirm `terminal-ai` is on PATH: `which terminal-ai`.
       - Test JSON path: `TERMINAL_AI_JSON=1 terminal-ai "list all files" | jq .`.

## Development Notes

- `ai-core/engine.go` assembles a contextual prompt from:
       - `command_history`, `last_command_output`, `user_clipboard`, and `user_query`.
- Calls Gemini `gemini-pro:generateContent`, expects a single raw command in response.
- Fallback returns the input command if API fails; never blocks the adapter.

## Roadmap (Optional)

- Improve context capture (shell history, last output, clipboard).
- Add tests and CI.
- Support additional providers (OpenAI, local models).

## License

MIT


#!/usr/bin/env bash
#
# Terminal AI - Bash Adapter
# This script integrates terminal-ai suggestions into Bash
#

# Check if terminal-ai is installed
if ! command -v terminal-ai &> /dev/null; then
    echo "Warning: terminal-ai not found in PATH"
    return 1
fi

# Function to get AI suggestion
terminal_ai_suggest() {
    local current_line="${READLINE_LINE}"
    
    # Only proceed if there's something typed
    if [[ -z "$current_line" ]]; then
        return
    fi
    
    # Get suggestion from terminal-ai (using JSON mode for parsing)
    local suggestion
    suggestion=$(TERMINAL_AI_JSON=1 terminal-ai "$current_line" 2>/dev/null | jq -r '.command' 2>/dev/null)
    
    # If we got a suggestion, replace the line
    if [[ -n "$suggestion" ]]; then
        READLINE_LINE="$suggestion"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# Bind to Ctrl+Space (you can change this to your preference)
bind -x '"\C- ": terminal_ai_suggest'

echo "Terminal AI loaded (Bash). Press Ctrl+Space to get AI suggestions."

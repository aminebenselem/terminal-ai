#!/usr/bin/env zsh
#
# Terminal AI - Zsh Adapter
# This script integrates terminal-ai suggestions into Zsh
#

# Check if terminal-ai is installed
if ! command -v terminal-ai &> /dev/null; then
    echo "Warning: terminal-ai not found in PATH"
    return 1
fi

# Function to get AI suggestion
terminal_ai_suggest() {
    local current_buffer="$BUFFER"
    
    # Only proceed if there's something typed
    if [[ -z "$current_buffer" ]]; then
        return
    fi
    
    # Get suggestion from terminal-ai (using JSON mode for parsing)
    local suggestion
    suggestion=$(TERMINAL_AI_JSON=1 terminal-ai "$current_buffer" 2>/dev/null | jq -r '.command' 2>/dev/null)
    
    # If we got a suggestion, replace the buffer
    if [[ -n "$suggestion" ]]; then
        BUFFER="$suggestion"
        CURSOR=${#BUFFER}
    fi
}

# Create a Zsh widget for the AI suggestion function
zle -N terminal_ai_suggest

# Bind to Ctrl+Space (you can change this to your preference)
bindkey '^ ' terminal_ai_suggest

# Optional: Add to right prompt to show AI is active
# RPROMPT="%F{cyan}[AI]%f $RPROMPT"

echo "Terminal AI loaded (Zsh). Press Ctrl+Space to get AI suggestions."

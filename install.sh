#!/usr/bin/env bash
#
# Terminal AI Installation Script
# This script installs the CLI binary and shell adapters
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Installation directories
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="terminal-ai"
CORE_BINARY="terminal-ai-core"

echo -e "${GREEN}Terminal AI Installation${NC}"
echo "================================"

# Check if running with sufficient privileges
check_permissions() {
    if [ ! -w "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Warning: No write permission to $INSTALL_DIR${NC}"
        echo "You may need to run this script with sudo"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Build the Go binary
build_binary() {
    echo -e "\n${GREEN}Building AI core engine...${NC}"
    
    if ! command -v go &> /dev/null; then
        echo -e "${RED}Error: Go is not installed${NC}"
        echo "Please install Go 1.21 or later from https://golang.org/"
        exit 1
    fi
    
    cd ai-core
    go build -ldflags="-s -w" -o "$CORE_BINARY" engine.go
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Build failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Build successful${NC}"
    cd ..
}

# Install the binaries
install_binaries() {
    echo -e "\n${GREEN}Installing binaries...${NC}"
    
    # Install core binary
    sudo cp "ai-core/$CORE_BINARY" "$INSTALL_DIR/$CORE_BINARY"
    sudo chmod +x "$INSTALL_DIR/$CORE_BINARY"
    echo -e "${GREEN}✓ Installed $CORE_BINARY to $INSTALL_DIR${NC}"
    
    # Install CLI launcher
    sudo cp "cli/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
    sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    echo -e "${GREEN}✓ Installed $BINARY_NAME to $INSTALL_DIR${NC}"
}

# Install shell adapter
install_adapter() {
    local shell_type=$(basename "$SHELL")
    local rc_file=""
    local adapter_file=""
    
    echo -e "\n${GREEN}Installing shell adapter...${NC}"
    echo "Detected shell: $shell_type"
    
    case "$shell_type" in
        zsh)
            rc_file="$HOME/.zshrc"
            adapter_file="adapters/adapter.zsh"
            ;;
        bash)
            rc_file="$HOME/.bashrc"
            adapter_file="adapters/adapter.bash"
            ;;
        *)
            echo -e "${YELLOW}Unknown shell, installing POSIX adapter${NC}"
            rc_file="$HOME/.profile"
            adapter_file="adapters/adapter.posix"
            ;;
    esac
    
    # Check if adapter is already sourced
    if grep -q "terminal-ai" "$rc_file" 2>/dev/null; then
        echo -e "${YELLOW}Adapter already configured in $rc_file${NC}"
    else
        echo -e "\n# Terminal AI integration" >> "$rc_file"
        echo "source $(pwd)/$adapter_file" >> "$rc_file"
        echo -e "${GREEN}✓ Added adapter to $rc_file${NC}"
    fi
}

# Main installation
main() {
    check_permissions
    build_binary
    install_binaries
    install_adapter
    
    echo -e "\n${GREEN}Installation complete!${NC}"
    echo -e "\nTo start using Terminal AI:"
    echo -e "  1. Restart your shell or run: ${YELLOW}source ~/.${SHELL##*/}rc${NC}"
    echo -e "  2. Try: ${YELLOW}terminal-ai \"list all files\"${NC}"
    echo -e "  3. In shell: Type a command and press ${YELLOW}Ctrl+Space${NC} for AI suggestions"
    echo ""
}

main

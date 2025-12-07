#!/bin/bash

# Enhanced script to sync nvim config between ~/.config/nvim and dotfiles repo
# Usage: ./sync-nvim.sh [push|pull|status|backup]

NVIM_CONFIG="$HOME/.config/nvim"
DOTFILES_NVIM="$HOME/dotfiles/nvim"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_status() {
    echo -e "${BLUE}📊 Neovim Config Status${NC}"
    echo "=========================="
    echo -e "${YELLOW}Active config:${NC} $NVIM_CONFIG"
    echo -e "${YELLOW}Dotfiles backup:${NC} $DOTFILES_NVIM"
    echo ""
    
    if [[ -d "$NVIM_CONFIG" ]]; then
        echo -e "${GREEN}✅ Active config exists${NC}"
        echo "   Files: $(find "$NVIM_CONFIG" -type f | wc -l)"
        echo "   Size: $(du -sh "$NVIM_CONFIG" | cut -f1)"
        echo "   Last modified: $(stat -c %y "$NVIM_CONFIG" | cut -d' ' -f1)"
    else
        echo -e "${RED}❌ No active config found${NC}"
    fi
    
    echo ""
    
    if [[ -d "$DOTFILES_NVIM" ]]; then
        echo -e "${GREEN}✅ Dotfiles backup exists${NC}"
        echo "   Files: $(find "$DOTFILES_NVIM" -type f | wc -l)"
        echo "   Size: $(du -sh "$DOTFILES_NVIM" | cut -f1)"
        echo "   Last modified: $(stat -c %y "$DOTFILES_NVIM" | cut -d' ' -f1)"
    else
        echo -e "${RED}❌ No dotfiles backup found${NC}"
    fi
}

case "${1:-status}" in
    "push")
        echo -e "${BLUE}📤 Copying nvim config TO dotfiles repo...${NC}"
        if [[ ! -d "$NVIM_CONFIG" ]]; then
            echo -e "${RED}❌ No active config found at $NVIM_CONFIG${NC}"
            exit 1
        fi
        
        # Create backup directory if it doesn't exist
        mkdir -p "$(dirname "$DOTFILES_NVIM")"
        
        rsync -av --delete --exclude='lazy-lock.json' "$NVIM_CONFIG/" "$DOTFILES_NVIM/"
        echo -e "${GREEN}✅ Nvim config copied to dotfiles repo${NC}"
        echo -e "${YELLOW}💡 Don't forget to commit changes: cd ~/dotfiles && git add . && git commit -m 'Update nvim config'${NC}"
        ;;
        
    "pull")
        echo -e "${BLUE}📥 Copying nvim config FROM dotfiles repo...${NC}"
        if [[ ! -d "$DOTFILES_NVIM" ]]; then
            echo -e "${RED}❌ No dotfiles backup found at $DOTFILES_NVIM${NC}"
            exit 1
        fi
        
        # Create active config directory if it doesn't exist
        mkdir -p "$NVIM_CONFIG"
        
        rsync -av --delete "$DOTFILES_NVIM/" "$NVIM_CONFIG/"
        echo -e "${GREEN}✅ Nvim config copied from dotfiles repo${NC}"
        ;;
        
    "backup")
        echo -e "${BLUE}💾 Creating timestamped backup...${NC}"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_DIR="$HOME/dotfiles/nvim_backups/nvim_$TIMESTAMP"
        
        if [[ ! -d "$NVIM_CONFIG" ]]; then
            echo -e "${RED}❌ No active config found at $NVIM_CONFIG${NC}"
            exit 1
        fi
        
        mkdir -p "$(dirname "$BACKUP_DIR")"
        cp -r "$NVIM_CONFIG" "$BACKUP_DIR"
        echo -e "${GREEN}✅ Backup created at $BACKUP_DIR${NC}"
        ;;
        
    "status")
        show_status
        ;;
        
    *)
        echo -e "${BLUE}Neovim Configuration Manager${NC}"
        echo "Usage: $0 [push|pull|status|backup]"
        echo ""
        echo -e "${YELLOW}Commands:${NC}"
        echo "  ${GREEN}status${NC}  - Show current status (default)"
        echo "  ${GREEN}push${NC}    - Copy ~/.config/nvim → dotfiles/nvim"
        echo "  ${GREEN}pull${NC}    - Copy dotfiles/nvim → ~/.config/nvim"
        echo "  ${GREEN}backup${NC}  - Create timestamped backup"
        echo ""
        echo -e "${YELLOW}Examples:${NC}"
        echo "  $0 push     # Save current config to dotfiles"
        echo "  $0 status   # Check sync status"
        exit 1
        ;;
esac
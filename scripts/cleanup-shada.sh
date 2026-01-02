#!/bin/bash
# Cleanup Neovim ShaDa temporary files
# This script removes all temporary ShaDa files that can prevent Neovim from writing

SHADA_DIR="$HOME/.local/state/nvim/shada"

if [ -d "$SHADA_DIR" ]; then
    # Remove all temporary files
    find "$SHADA_DIR" -name "main.shada.tmp.*" -type f -delete
    echo "Cleaned up ShaDa temporary files"
else
    echo "ShaDa directory not found: $SHADA_DIR"
fi

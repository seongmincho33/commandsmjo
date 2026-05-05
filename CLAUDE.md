# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DX Kit (Developer Experience Kit) is an interactive command-line menu system for macOS/Linux (Zsh) and Windows (PowerShell). It provides quick access to commonly-used development commands through a numbered menu interface, invoked with the `dxk` command (legacy alias `gg` also works).

## Installation

```bash
# macOS/Linux
./install.sh              # Install
./install.sh --uninstall  # Uninstall

# Windows PowerShell
.\install_windows.ps1
.\install_windows.ps1 --uninstall
```

Installation copies `menu.zsh` to `~/.zsh_menu/` and adds a source line to `~/.zshrc`.

## Architecture

### Main Components

- **menu.zsh** (~4400 lines): Core interactive menu with all functionality
  - Main entry: `seongmin()` function (aliased as `gg`)
  - Submenu functions: `_seongmin_<category>()` (e.g., `_seongmin_git`, `_seongmin_python`)
  - Deep nesting for complex tools like Git: `_seongmin_git_basic`, `_seongmin_git_flow`, etc.

- **install.sh**: Bash installer for macOS/Linux
  - OS detection, directory setup, shell configuration
  - Creates backups before modifying `.zshrc`

- **install_windows.ps1**: PowerShell installer for Windows

### Module Files (Alias Collections)

Lightweight alias files that can be sourced independently:
- `git.zsh` - Git shortcuts (`gs`, `ga`, `gc`, `gp`, etc.)
- `python.zsh` - Python/venv aliases and helpers (`py`, `pv`, `pynew()`)
- `java.zsh` - Java/Gradle/Maven shortcuts
- `docker.zsh` - Docker management aliases
- `homebrew.zsh`, `redis.zsh`, `shell.zsh`, `version.zsh`

### Menu Categories

1. Git (8 subcategories)
2. Python
3. Java
4. Homebrew
5. Docker
6. Redis
7. Shell
8. Version Checking
9. Frontend
10. Jenkins
11. Claude Code

## Code Style

- Zsh functions with ANSI color codes for UI
- Korean language for menu text and messages
- ASCII art boxes for visual structure
- Interactive `read` for user input with numbered choices

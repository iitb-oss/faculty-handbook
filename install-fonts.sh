#!/bin/bash

# Installs the following fonts:
# - Times New Roman 
# - Ubuntu fonts 
# - Latin Modern fonts
# - Latin Modern Math
#
# Last updated: September 2025

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install fonts on macOS
install_fonts_macos() {
    log_info "Installing fonts on macOS..."

    # Check if Homebrew is installed
    if ! command_exists brew; then
        log_error "Homebrew is required but not installed. Please install Homebrew first:"
        log_error "Visit: https://brew.sh/"
        exit 1
    fi

    # Add homebrew-cask-fonts tap if not already added
    log_info "Adding homebrew-cask-fonts tap..."
    brew tap homebrew/cask-fonts 2>/dev/null || log_warn "Font tap may already be added"

    log_info "Installing Latin Modern fonts..."
    if brew install --cask font-latin-modern 2>/dev/null; then
        log_info "✓ Latin Modern fonts installed successfully"
    else
        log_warn "Latin Modern fonts may already be installed or failed to install"
    fi

    log_info "Installing Ubuntu fonts..."
    if brew install --cask font-ubuntu 2>/dev/null; then
        log_info "✓ Ubuntu fonts installed successfully"
    else
        log_warn "Ubuntu fonts may already be installed or failed to install"
    fi

    log_info "Installing Latin Modern Math fonts..."
    if brew install --cask font-latin-modern-math 2>/dev/null; then
        log_info "✓ Latin Modern Math fonts installed successfully"
    else
        log_warn "Latin Modern Math fonts may already be installed or failed to install"
    fi

    # Refresh font cache
    log_info "Refreshing font cache..."
    if command_exists fc-cache; then
        fc-cache -f -v 2>/dev/null
        log_info "Font cache refreshed"
    else
        log_warn "fc-cache not available, but macOS should handle font updates automatically"
    fi
}

# Install fonts on Linux
install_fonts_linux() {
    log_info "Installing fonts on Linux..."

    # Detect package manager
    if command_exists apt-get; then
        PKG_MANAGER="apt"
    elif command_exists yum; then
        PKG_MANAGER="yum"
    elif command_exists dnf; then
        PKG_MANAGER="dnf"
    elif command_exists pacman; then
        PKG_MANAGER="pacman"
    else
        log_error "No supported package manager found (apt, yum, dnf, pacman)"
        exit 1
    fi

    log_info "Using package manager: $PKG_MANAGER"

    # Install fonts based on package manager
    case $PKG_MANAGER in
        "apt")
            sudo apt-get update
            sudo apt-get install -y \
                lmodern \
                fonts-liberation \
                fonts-ubuntu \
                fontconfig
            ;;
        "yum"|"dnf")
            sudo $PKG_MANAGER install -y \
                texlive-lm \
                liberation-fonts \
                google-noto-fonts \
                fontconfig
            # Ubuntu fonts may need manual installation on RHEL-based systems
            install_ubuntu_fonts_manual
            ;;
        "pacman")
            sudo pacman -S --noconfirm \
                texlive-fontsextra \
                ttf-liberation \
                ttf-ubuntu-font-family \
                fontconfig
            ;;
    esac

    # Refresh font cache
    log_info "Refreshing font cache..."
    fc-cache -f -v
}

# Manual Ubuntu fonts installation for systems without package
install_ubuntu_fonts_manual() {
    log_info "Installing Ubuntu fonts manually..."

    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download Ubuntu fonts
    wget -q "https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip" -O ubuntu-fonts.zip
    unzip -q ubuntu-fonts.zip

    # Copy font files
    find . -name "*.ttf" -exec cp {} "$FONT_DIR/" \;

    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"

    log_info "Ubuntu fonts installed to $FONT_DIR"
}

# Verify fonts are installed
verify_fonts() {
    log_info "Verifying font installations..."

    if ! command_exists fc-list; then
        log_warn "fc-list command not available, cannot verify fonts"
        log_info "On macOS, fonts should be available through Font Book"
        return 0
    fi

    FONTS_TO_CHECK=(
        "Times New Roman"
        "Ubuntu"
        "LM"
    )

    MISSING_FONTS=0
    FOUND_FONTS=()

    for font in "${FONTS_TO_CHECK[@]}"; do
        if fc-list | grep -i "$font" >/dev/null 2>&1; then
            log_info "✓ Found font family: $font"
            FOUND_FONTS+=("$font")
        else
            log_warn "✗ Font family not found: $font"
            MISSING_FONTS=$((MISSING_FONTS + 1))
        fi
    done

    # Show detailed font information for found fonts
    if [ ${#FOUND_FONTS[@]} -gt 0 ]; then
        log_info "Detected font details:"
        for font in "${FOUND_FONTS[@]}"; do
            case $font in
                "Times New Roman")
                    fc-list | grep -i "times new roman" | head -3 | while read line; do
                        log_info "  - ${line%%:*}"
                    done
                    ;;
                "Ubuntu")
                    fc-list | grep -i "ubuntu" | head -3 | while read line; do
                        log_info "  - ${line%%:*}"
                    done
                    ;;
                "LM")
                    fc-list | grep -i "lm" | head -3 | while read line; do
                        log_info "  - ${line%%:*}"
                    done
                    ;;
            esac
        done
    fi

    if [ $MISSING_FONTS -eq 0 ]; then
        log_info "All required fonts are available!"
        return 0
    else
        log_warn "$MISSING_FONTS font families are missing or not detected"
        log_warn "The handbook may still build successfully with font substitution"
        return 1
    fi
}

# Main installation function
main() {
    echo "Faculty Handbook Font Installer"
    echo "==============================="

    PLATFORM=$(detect_platform)

    case $PLATFORM in
        "macos")
            install_fonts_macos
            ;;
        "linux")
            install_fonts_linux
            ;;
        "unsupported")
            log_error "Unsupported platform: $OSTYPE"
            log_error "This script supports macOS and Linux only"
            exit 1
            ;;
    esac

    echo
    log_info "Font installation completed!"

    # Verify installation
    echo
    verify_fonts

    echo
    log_info "You can now run 'make' to build the handbook PDF"
    log_info "If you encounter font issues, you may need to restart your terminal"
}

main "$@"

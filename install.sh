#!/bin/bash

# VPN Manager - Installation Script
# Author: r3vpwnx

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                    VPN MANAGER                             ║
║              OpenVPN Manager for CTF                       ║
║                   Installation Script                      ║
║                   Author: r3vpwnx                          ║
╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root"
        echo "Please run as normal user. Sudo will be used when needed."
        exit 1
    fi
}

install_dependencies() {
    echo
    print_info "Checking dependencies..."
    
    local missing_deps=()
    
    # Check OpenVPN
    if ! command -v openvpn &> /dev/null; then
        missing_deps+=("openvpn")
    else
        print_success "OpenVPN is installed"
    fi
    
    # Check bc (for calculations)
    if ! command -v bc &> /dev/null; then
        missing_deps+=("bc")
    else
        print_success "bc is installed"
    fi
    
    # Check curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    else
        print_success "curl is installed"
    fi
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "All dependencies are already installed!"
        return 0
    fi
    
    echo
    print_warning "Missing dependencies: ${missing_deps[*]}"
    echo
    read -p "Install missing dependencies? [Y/n] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_error "Installation cannot continue without dependencies"
        exit 1
    fi
    
    print_info "Installing dependencies..."
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y "${missing_deps[@]}"
    elif command -v yum &> /dev/null; then
        sudo yum install -y "${missing_deps[@]}"
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm "${missing_deps[@]}"
    else
        print_error "Could not detect package manager"
        echo "Please install manually: ${missing_deps[*]}"
        exit 1
    fi
    
    print_success "Dependencies installed successfully!"
}

setup_vpn_directory() {
    echo
    print_info "Setting up VPN directory..."
    
    local vpn_dir="$HOME/VPN"
    
    if [ ! -d "$vpn_dir" ]; then
        mkdir -p "$vpn_dir"
        print_success "Created VPN directory: $vpn_dir"
    else
        print_success "VPN directory already exists: $vpn_dir"
    fi
    
    # Check if there are any .ovpn files
    if [ -n "$(ls -A $vpn_dir/*.ovpn 2>/dev/null)" ]; then
        local count=$(ls -1 $vpn_dir/*.ovpn 2>/dev/null | wc -l)
        print_success "Found $count .ovpn file(s) in VPN directory"
    else
        print_warning "No .ovpn files found in VPN directory"
        echo
        echo -e "${YELLOW}Please place your .ovpn configuration files in:${NC}"
        echo -e "${CYAN}$vpn_dir/${NC}"
        echo
        echo -e "${BLUE}Example:${NC}"
        echo -e "  cp ~/Downloads/dante-prolab.ovpn $vpn_dir/"
        echo -e "  cp ~/Downloads/htb.ovpn $vpn_dir/"
    fi
}

install_script() {
    echo
    print_info "Installing VPN manager script..."
    
    local script_path="/usr/local/bin/vpn"
    
    # Copy script
    if sudo cp vpn "$script_path" 2>/dev/null; then
        sudo chmod +x "$script_path"
        print_success "Script installed to: $script_path"
    else
        print_error "Failed to install script"
        echo "Try manually: sudo cp vpn /usr/local/bin/vpn && sudo chmod +x /usr/local/bin/vpn"
        exit 1
    fi
    
    # Verify installation
    if command -v vpn &> /dev/null; then
        print_success "VPN command is now available globally!"
    else
        print_error "VPN command not found in PATH"
        exit 1
    fi
}

show_completion() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              INSTALLATION COMPLETE! 🎉                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}📋 Quick Start:${NC}"
    echo
    echo -e "  ${YELLOW}1.${NC} Place your .ovpn files in: ${CYAN}$HOME/VPN/${NC}"
    echo -e "  ${YELLOW}2.${NC} List available configs: ${GREEN}vpn --available${NC}"
    echo -e "  ${YELLOW}3.${NC} Connect to VPN: ${GREEN}vpn --<name>${NC}"
    echo -e "  ${YELLOW}4.${NC} Check status: ${GREEN}vpn --status${NC}"
    echo -e "  ${YELLOW}5.${NC} Disconnect: ${GREEN}vpn --terminate${NC}"
    echo
    echo -e "${CYAN}📚 Available Commands:${NC}"
    echo
    echo -e "  ${GREEN}vpn --dante-prolab${NC}    Connect to dante-prolab"
    echo -e "  ${GREEN}vpn --thm${NC}             Connect to TryHackMe"
    echo -e "  ${GREEN}vpn --htb${NC}             Connect to HackTheBox"
    echo -e "  ${GREEN}vpn --status${NC}          Show connection status"
    echo -e "  ${GREEN}vpn --available${NC}       List available configs"
    echo -e "  ${GREEN}vpn --terminate${NC}       Disconnect VPN"
    echo -e "  ${GREEN}vpn --help${NC}            Show all commands"
    echo
    echo -e "${BLUE}💡 Pro Tip:${NC} The script uses colored output for better visibility!"
    echo -e "${BLUE}💡 Pro Tip:${NC} OpenVPN requires sudo privileges to connect"
    echo
    echo -e "${MAGENTA}Created by: r0nt3x${NC}"
    echo
}

main() {
    print_banner
    check_root
    install_dependencies
    setup_vpn_directory
    install_script
    show_completion
}

main

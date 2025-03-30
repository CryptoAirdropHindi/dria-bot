#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'
WHITE='\033[1;37m'

# Function to display header
display_header() {
    clear
    echo -e "${CYAN}"
    echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${NC}"
    echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${NC}"
    echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${NC}"
    echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${NC}"
    echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${NC}"
    echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${GREEN}       ✨ dria Node Installation Script ✨${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${CYAN} Telegram Channel: CryptoAirdropHindi @CryptoAirdropHindi ${NC}"  
    echo -e "${CYAN} Follow us on social media for updates and more ${NC}"
    echo -e " 📱 Telegram: https://t.me/CryptoAirdropHindi6 "
    echo -e " 🎥 YouTube: https://www.youtube.com/@CryptoAirdropHindi6 "
    echo -e " 💻 GitHub Repo: https://github.com/CryptoAirdropHindi/ "
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Function to display success messages
success_message() {
    echo -e "${GREEN}[✅] $1${NC}"
}

# Function to display info messages
info_message() {
    echo -e "${CYAN}[ℹ️] $1${NC}"
}

# Function to display error messages
error_message() {
    echo -e "${RED}[❌] $1${NC}"
}

# Function to display warning messages
warning_message() {
    echo -e "${YELLOW}[⚠️] $1${NC}"
}

# Function to install dependencies
install_dependencies() {
    info_message "Installing required packages..."
    sudo apt update && sudo apt-get upgrade -y
    sudo apt install -y git make jq build-essential gcc unzip wget lz4 aria2 curl
    success_message "Dependencies installed"
}

# Check if curl is installed and install if not
if ! command -v curl &> /dev/null; then
    sudo apt update
    sudo apt install curl -y
fi

# Function to print menu
print_menu() {
    display_header
    echo -e "${BOLD}${BLUE}🔧 Available actions:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}➜ ${WHITE}🛠️  Install node${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}➜ ${WHITE}▶️  Start node${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}➜ ${WHITE}⬆️  Update node${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}➜ ${WHITE}🔌 Change port${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}➜ ${WHITE}📋 Check logs${NC}"
    echo -e "${WHITE}[${CYAN}6${WHITE}] ${GREEN}➜ ${WHITE}🗑️  Remove node${NC}"
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}🚪 Exit${NC}\n"
}

# Function to install node
install_node() {
    display_header
    echo -e "\n${BOLD}${BLUE}⚡ Installing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}🔄 Installing dependencies...${NC}"
    install_dependencies

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading installer...${NC}"
    info_message "Downloading and installing Dria Compute Node..."
    curl -fsSL https://dria.co/launcher | bash
    success_message "Installer downloaded and executed"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🚀 Starting node...${NC}"
    dkn-compute-launcher start

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${GREEN}✨ Node successfully installed and started!${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Function to start node as a service
start_node_service() {
    display_header
    echo -e "\n${BOLD}${BLUE}🚀 Starting Dria node as a service...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Creating service file...${NC}"
    USERNAME=$(whoami)
    HOME_DIR=$(eval echo ~$USERNAME)
    
    # Check if .env file exists
    if [ ! -f "$HOME_DIR/.dria/dkn-compute-launcher/.env" ]; then
        error_message "Environment file not found! Please install the node first."
        return 1
    fi

    sudo bash -c "cat <<EOT > /etc/systemd/system/dria.service
[Unit]
Description=Dria Compute Node Service
After=network.target

[Service]
Type=simple
User=$USERNAME
WorkingDirectory=$HOME_DIR/.dria/dkn-compute-launcher/
EnvironmentFile=$HOME_DIR/.dria/dkn-compute-launcher/.env
ExecStart=/usr/local/bin/dkn-compute-launcher start
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOT"
    success_message "Service file created"

    echo -e "${WHITE}[${CYAN}2/4${WHITE}] ${GREEN}➜ ${WHITE}🔄 Reloading systemd...${NC}"
    sudo systemctl daemon-reload
    success_message "Systemd reloaded"

    echo -e "${WHITE}[${CYAN}3/4${WHITE}] ${GREEN}➜ ${WHITE}🔧 Enabling service...${NC}"
    sudo systemctl enable dria
    success_message "Service enabled"

    echo -e "${WHITE}[${CYAN}4/4${WHITE}] ${GREEN}➜ ${WHITE}🚀 Starting service...${NC}"
    sudo systemctl start dria
    sleep 2  # Give it time to start
    
    # Check if service is running
    if systemctl is-active --quiet dria; then
        success_message "Service started successfully"
    else
        error_message "Failed to start service!"
        echo -e "${YELLOW}Check logs with: journalctl -u dria -f --no-hostname -o cat${NC}"
        return 1
    fi

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${YELLOW}📝 Command to check logs:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"

    sudo journalctl -u dria -f --no-hostname -o cat
}

# [Rest of your functions remain the same...]

# Main program loop
while true; do
    print_menu
    echo -e "${BOLD}${BLUE}📝 Enter action number [1-7]:${NC} "
    read -p "➜ " choice

    case $choice in
        1) install_node ;;
        2) start_node_service ;;
        3) update_node ;;
        4) change_port ;;
        5) check_logs ;;
        6) remove_node ;;
        7)
            display_header
            echo -e "\n${BLUE}=======================================================${NC}"
            echo -e "${GREEN}👋 Goodbye!${NC}"
            echo -e "${BLUE}=======================================================${NC}\n"
            exit 0
            ;;
        *)
            display_header
            echo -e "\n${RED}❌ Error: Invalid choice! Please enter a number from 1 to 7.${NC}\n"
            ;;
    esac
    
    if [ "$choice" != "2" ] && [ "$choice" != "4" ] && [ "$choice" != "5" ]; then
        echo -e "\nPress Enter to return to menu..."
        read
    fi
done

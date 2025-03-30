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
    sudo apt install -y git make jq build-essential gcc unzip wget lz4 aria2 curl ufw miniupnpc
    success_message "Dependencies installed"
}

# Function to install Ollama
install_ollama() {
    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading Ollama...${NC}"
    curl -fsSL https://ollama.com/install.sh | sh
    
    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}🚀 Starting Ollama service...${NC}"
    sudo systemctl enable ollama
    sudo systemctl start ollama
    
    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🔍 Verifying installation...${NC}"
    if ollama --version; then
        success_message "Ollama installed successfully"
    else
        error_message "Ollama installation failed!"
        return 1
    fi
}

# Function to configure network
configure_network() {
    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}🔧 Configuring firewall...${NC}"
    sudo ufw allow 3000/tcp
    sudo ufw allow 11434/tcp  # Ollama port
    sudo ufw --force enable
    success_message "Firewall configured"

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}🌐 Checking NAT configuration...${NC}"
    if which upnpc >/dev/null; then
        success_message "UPnP/NAT-PMP available"
    else
        warning_message "UPnP/NAT-PMP not installed - NAT traversal may be limited"
    fi

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}📡 Testing network connectivity...${NC}"
    if curl -Is https://dria.co | head -n 1 | grep -q 200; then
        success_message "Network connectivity OK"
    else
        error_message "Network connectivity issues detected"
        return 1
    fi
}

# Function to install node
install_node() {
    display_header
    echo -e "\n${BOLD}${BLUE}⚡ Installing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/7${WHITE}] ${GREEN}➜ ${WHITE}🔄 Installing dependencies...${NC}"
    install_dependencies

    echo -e "${WHITE}[${CYAN}2/7${WHITE}] ${GREEN}➜ ${WHITE}🌐 Configuring network...${NC}"
    configure_network || return 1

    echo -e "${WHITE}[${CYAN}3/7${WHITE}] ${GREEN}➜ ${WHITE}🤖 Installing Ollama...${NC}"
    if ! command -v ollama &> /dev/null; then
        install_ollama || return 1
    else
        success_message "Ollama already installed"
    fi

    echo -e "${WHITE}[${CYAN}4/7${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading Dria installer...${NC}"
    curl -fsSL https://dria.co/launcher | bash
    success_message "Installer downloaded and executed"

    echo -e "${WHITE}[${CYAN}5/7${WHITE}] ${GREEN}➜ ${WHITE}🔑 Setting up API keys...${NC}"
    if [ ! -f ~/.dria/dkn-compute-launcher/.env ]; then
        read -p "Enter your SERPER_API_KEY: " SERPER_API_KEY
        echo "SERPER_API_KEY=$SERPER_API_KEY" > ~/.dria/dkn-compute-launcher/.env
        success_message "API key configured"
    else
        success_message "API key already exists"
    fi

    echo -e "${WHITE}[${CYAN}6/7${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Configuring models and network...${NC}"
    mkdir -p ~/.dria/dkn-compute-launcher/
    cat > ~/.dria/dkn-compute-launcher/config.toml <<EOL
[models]
ollama = true

[ollama]
default_models = [
    "llama3.2:1b",
    "qwen2.5-coder:1.5b"
]

[network]
peer_discovery_interval = 30
connection_timeout = 60
reconnect_interval = 15
enable_mdns = true
EOL
    success_message "Configuration complete"

    echo -e "${WHITE}[${CYAN}7/7${WHITE}] ${GREEN}➜ ${WHITE}🚀 Starting node...${NC}"
    if dkn-compute-launcher start; then
        success_message "Node started successfully"
        echo -e "\n${YELLOW}💡 Troubleshooting tips:${NC}"
        echo -e "If experiencing connection issues:"
        echo -e "1. Check firewall: ${CYAN}sudo ufw status${NC}"
        echo -e "2. Forward port 3000 in your router"
        echo -e "3. Restart node: ${CYAN}dkn-compute-launcher restart${NC}"
    else
        error_message "Failed to start node!"
        return 1
    fi

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${GREEN}✨ Node installation completed!${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Function to start node as a service
start_node_service() {
    display_header
    echo -e "\n${BOLD}${BLUE}🚀 Starting Dria node as a service...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Creating service file...${NC}"
    USERNAME=$(whoami)
    HOME_DIR=$(eval echo ~$USERNAME)
    
    sudo bash -c "cat <<EOT > /etc/systemd/system/dria.service
[Unit]
Description=Dria Compute Node Service
After=network.target ollama.service

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
    sleep 5
    
    if systemctl is-active --quiet dria; then
        success_message "Service started successfully"
    else
        error_message "Failed to start service!"
        echo -e "${YELLOW}Check logs with: journalctl -u dria -f --no-hostname -o cat${NC}"
        return 1
    fi

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${YELLOW}📝 Node Status:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# [Rest of the functions remain the same...]

# Main menu function
print_menu() {
    display_header
    echo -e "${BOLD}${BLUE}🔧 Available actions:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}➜ ${WHITE}🛠️  Install node${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}➜ ${WHITE}⚙️  Configure models${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}➜ ${WHITE}▶️  Start node service${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}➜ ${WHITE}⬆️  Update node${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}➜ ${WHITE}🔌 Change port${NC}"
    echo -e "${WHITE}[${CYAN}6${WHITE}] ${GREEN}➜ ${WHITE}📋 Check logs${NC}"
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}🔄 Restart node${NC}"
    echo -e "${WHITE}[${CYAN}8${WHITE}] ${GREEN}➜ ${WHITE}🗑️  Remove node${NC}"
    echo -e "${WHITE}[${CYAN}9${WHITE}] ${GREEN}➜ ${WHITE}🚪 Exit${NC}\n"
}

# Main program loop
while true; do
    print_menu
    echo -e "${BOLD}${BLUE}📝 Enter action number [1-9]:${NC} "
    read -p "➜ " choice

    case $choice in
        1) install_node ;;
        2) configure_models ;;
        3) start_node_service ;;
        4) update_node ;;
        5) change_port ;;
        6) check_logs ;;
        7) 
            sudo systemctl restart dria
            success_message "Node restarted"
            ;;
        8) remove_node ;;
        9)
            display_header
            echo -e "\n${BLUE}=======================================================${NC}"
            echo -e "${GREEN}👋 Goodbye!${NC}"
            echo -e "${BLUE}=======================================================${NC}\n"
            exit 0
            ;;
        *)
            display_header
            echo -e "\n${RED}❌ Error: Invalid choice! Please enter a number from 1 to 9.${NC}\n"
            ;;
    esac
    
    if [ "$choice" != "3" ] && [ "$choice" != "6" ]; then
        echo -e "\nPress Enter to return to menu..."
        read
    fi
done

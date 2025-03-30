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

# Function to install node
install_node() {
    display_header
    echo -e "\n${BOLD}${BLUE}⚡ Installing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/6${WHITE}] ${GREEN}➜ ${WHITE}🔄 Installing dependencies...${NC}"
    install_dependencies

    echo -e "${WHITE}[${CYAN}2/6${WHITE}] ${GREEN}➜ ${WHITE}🤖 Installing Ollama...${NC}"
    if ! command -v ollama &> /dev/null; then
        install_ollama || return 1
    else
        success_message "Ollama already installed"
    fi

    echo -e "${WHITE}[${CYAN}3/6${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading Dria installer...${NC}"
    curl -fsSL https://dria.co/launcher | bash
    success_message "Installer downloaded and executed"

    echo -e "${WHITE}[${CYAN}4/6${WHITE}] ${GREEN}➜ ${WHITE}🔑 Setting up API keys...${NC}"
    if [ ! -f ~/.dria/dkn-compute-launcher/.env ]; then
        read -p "Enter your SERPER_API_KEY: " SERPER_API_KEY
        echo "SERPER_API_KEY=$SERPER_API_KEY" > ~/.dria/dkn-compute-launcher/.env
        success_message "API key configured"
    else
        success_message "API key already exists"
    fi

    echo -e "${WHITE}[${CYAN}5/6${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Configuring models...${NC}"
    mkdir -p ~/.dria/dkn-compute-launcher/
    cat > ~/.dria/dkn-compute-launcher/config.toml <<EOL
[models]
ollama = true
EOL
    success_message "Models configured"

    echo -e "${WHITE}[${CYAN}6/6${WHITE}] ${GREEN}➜ ${WHITE}🚀 Starting node...${NC}"
    if dkn-compute-launcher start; then
        success_message "Node started successfully"
    else
        error_message "Failed to start node!"
        echo -e "${YELLOW}Try manually: dkn-compute-launcher start${NC}"
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
    sleep 2
    
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
}

# Function to update node
update_node() {
    display_header
    echo -e "\n${BOLD}${BLUE}⬆️ Updating Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}🛑 Stopping service...${NC}"
    sudo systemctl stop dria
    sleep 3
    success_message "Service stopped"

    echo -e "${WHITE}[${CYAN}2/4${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading updates...${NC}"
    sudo rm /usr/local/bin/dkn-compute-launcher 2>/dev/null
    curl -fsSL https://dria.co/launcher | bash
    sleep 3

    echo -e "${WHITE}[${CYAN}3/4${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Copying binary file...${NC}"
    sudo cp $HOME/.dria/bin/dkn-compute-launcher /usr/local/bin/dkn-compute-launcher
    sudo chmod +x /usr/local/bin/dkn-compute-launcher
    sudo systemctl daemon-reload
    sleep 3
    success_message "Updates downloaded and installed"

    echo -e "${WHITE}[${CYAN}4/4${WHITE}] ${GREEN}➜ ${WHITE}🚀 Restarting service...${NC}"
    sudo systemctl restart dria
    success_message "Service restarted"

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${GREEN}✨ Node successfully updated!${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Function to change port
change_port() {
    display_header
    echo -e "\n${BOLD}${BLUE}🔌 Changing Dria node port...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/3${WHITE}] ${GREEN}➜ ${WHITE}🛑 Stopping service...${NC}"
    sudo systemctl stop dria
    success_message "Service stopped"

    echo -e "${WHITE}[${CYAN}2/3${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Configuring new port...${NC}"
    echo -e "${YELLOW}🔢 Enter new port for Dria:${NC}"
    read -p "➜ " NEW_PORT

    ENV_FILE="$HOME/.dria/dkn-compute-launcher/.env"
    sed -i "s|DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/[0-9]*|DKN_P2P_LISTEN_ADDR=/ip4/0.0.0.0/tcp/$NEW_PORT|" "$ENV_FILE"
    success_message "Port changed to $NEW_PORT"

    echo -e "${WHITE}[${CYAN}3/3${WHITE}] ${GREEN}➜ ${WHITE}🚀 Restarting service...${NC}"
    sudo systemctl daemon-reload
    sudo systemctl start dria
    success_message "Service restarted with new port"

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${YELLOW}📝 Command to check logs:${NC}"
    echo -e "${CYAN}sudo journalctl -u dria -f --no-hostname -o cat${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Function to check logs
check_logs() {
    display_header
    echo -e "\n${BOLD}${BLUE}📋 Checking Dria node logs...${NC}\n"
    sudo journalctl -u dria -f --no-hostname -o cat
}

# Function to remove node
remove_node() {
    display_header
    echo -e "\n${BOLD}${RED}⚠️ Removing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/2${WHITE}] ${GREEN}➜ ${WHITE}🛑 Stopping services...${NC}"
    sudo systemctl stop dria
    sudo systemctl disable dria
    sudo rm /etc/systemd/system/dria.service
    sudo systemctl daemon-reload
    sleep 2
    success_message "Services stopped and removed"

    echo -e "${WHITE}[${CYAN}2/2${WHITE}] ${GREEN}➜ ${WHITE}🗑️ Removing files...${NC}"
    rm -rf $HOME/.dria
    rm -rf ~/dkn-compute-node
    success_message "Node files removed"

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${GREEN}✅ Dria node successfully removed!${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
    sleep 2
}

# Function to configure models
configure_models() {
    display_header
    echo -e "\n${BOLD}${BLUE}⚙️ Configuring Dria models...${NC}\n"
    
    echo -e "${YELLOW}Manual configuration required:${NC}"
    echo -e "1. Edit the config file:"
    echo -e "${CYAN}nano ~/.dria/dkn-compute-launcher/config.toml${NC}"
    echo -e "\n2. Add your preferred models (example):"
    echo -e "${CYAN}[models]"
    echo -e "ollama = true"
    echo -e "# openai = true${NC}"
    echo -e "\n3. Save the file and restart the node"
    
    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${YELLOW}📝 Press Enter to open the editor, or Ctrl+C to cancel${NC}"
    read
    nano ~/.dria/dkn-compute-launcher/config.toml
}

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
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}🗑️  Remove node${NC}"
    echo -e "${WHITE}[${CYAN}8${WHITE}] ${GREEN}➜ ${WHITE}🚪 Exit${NC}\n"
}

# Main program loop
while true; do
    print_menu
    echo -e "${BOLD}${BLUE}📝 Enter action number [1-8]:${NC} "
    read -p "➜ " choice

    case $choice in
        1) install_node ;;
        2) configure_models ;;
        3) start_node_service ;;
        4) update_node ;;
        5) change_port ;;
        6) check_logs ;;
        7) remove_node ;;
        8)
            display_header
            echo -e "\n${BLUE}=======================================================${NC}"
            echo -e "${GREEN}👋 Goodbye!${NC}"
            echo -e "${BLUE}=======================================================${NC}\n"
            exit 0
            ;;
        *)
            display_header
            echo -e "\n${RED}❌ Error: Invalid choice! Please enter a number from 1 to 8.${NC}\n"
            ;;
    esac
    
    if [ "$choice" != "3" ] && [ "$choice" != "6" ]; then
        echo -e "\nPress Enter to return to menu..."
        read
    fi
done

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

# [Previous functions remain the same until install_node]

# Function to install node
install_node() {
    display_header
    echo -e "\n${BOLD}${BLUE}⚡ Installing Dria node...${NC}\n"

    echo -e "${WHITE}[${CYAN}1/4${WHITE}] ${GREEN}➜ ${WHITE}🔄 Installing dependencies...${NC}"
    install_dependencies

    echo -e "${WHITE}[${CYAN}2/4${WHITE}] ${GREEN}➜ ${WHITE}📥 Downloading installer...${NC}"
    info_message "Downloading and installing Dria Compute Node..."
    curl -fsSL https://dria.co/launcher | bash
    success_message "Installer downloaded and executed"

    echo -e "${WHITE}[${CYAN}3/4${WHITE}] ${GREEN}➜ ${WHITE}⚙️ Configuring models...${NC}"
    # Automatically configure ollama as default model
    if [ -f "$HOME/.dria/dkn-compute-launcher/config.toml" ]; then
        sed -i 's/^\[models\]$/\[models\]\nollama = true/' "$HOME/.dria/dkn-compute-launcher/config.toml"
        success_message "Configured ollama as default model"
    else
        warning_message "Config file not found, you'll need to manually select models"
        echo -e "${YELLOW}Run: dkn-compute-launcher models edit${NC}"
        echo -e "${YELLOW}Select ollama (option 1) and press Enter${NC}"
        sleep 5
    fi

    echo -e "${WHITE}[${CYAN}4/4${WHITE}] ${GREEN}➜ ${WHITE}🚀 Starting node...${NC}"
    if dkn-compute-launcher start; then
        success_message "Node started successfully"
    else
        error_message "Failed to start node!"
        echo -e "${YELLOW}Please check the logs and configure models if needed${NC}"
        return 1
    fi

    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${GREEN}✨ Node installation completed!${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Function to handle model selection
configure_models() {
    display_header
    echo -e "\n${BOLD}${BLUE}⚙️ Configuring Dria models...${NC}\n"
    
    echo -e "${YELLOW}Available model providers:${NC}"
    echo -e "1) ollama"
    echo -e "2) openai"
    echo -e "\n${YELLOW}Select providers (space to select, enter to confirm):${NC}"
    
    # Run the model configuration interactively
    dkn-compute-launcher models edit
    
    echo -e "\n${BLUE}=======================================================${NC}"
    echo -e "${GREEN}✅ Model configuration updated!${NC}"
    echo -e "${BLUE}=======================================================${NC}\n"
}

# Update the menu function
print_menu() {
    display_header
    echo -e "${BOLD}${BLUE}🔧 Available actions:${NC}\n"
    echo -e "${WHITE}[${CYAN}1${WHITE}] ${GREEN}➜ ${WHITE}🛠️  Install node${NC}"
    echo -e "${WHITE}[${CYAN}2${WHITE}] ${GREEN}➜ ${WHITE}⚙️  Configure models${NC}"
    echo -e "${WHITE}[${CYAN}3${WHITE}] ${GREEN}➜ ${WHITE}▶️  Start node${NC}"
    echo -e "${WHITE}[${CYAN}4${WHITE}] ${GREEN}➜ ${WHITE}⬆️  Update node${NC}"
    echo -e "${WHITE}[${CYAN}5${WHITE}] ${GREEN}➜ ${WHITE}🔌 Change port${NC}"
    echo -e "${WHITE}[${CYAN}6${WHITE}] ${GREEN}➜ ${WHITE}📋 Check logs${NC}"
    echo -e "${WHITE}[${CYAN}7${WHITE}] ${GREEN}➜ ${WHITE}🗑️  Remove node${NC}"
    echo -e "${WHITE}[${CYAN}8${WHITE}] ${GREEN}➜ ${WHITE}🚪 Exit${NC}\n"
}

# Update the main loop
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

#!/bin/bash

set -e

# ======================
# BASIC SYSTEM UPDATE AND UTILITY INSTALLATION
# ======================
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🧹 Installing basic utilities..."
sudo apt install -y nala gdebi-core curl wget git flatpak gnome-tweaks gnome-shell-extensions gnome-shell-extension-manager ufw unzip build-essential ca-certificates lsb-release apt-transport-https gnupg software-properties-common ubuntu-restricted-extras

# ======================
# FIREWALL CONFIGURATION
# ======================
echo "🔥 Configuring UFW Firewall..."
sudo ufw enable
sudo ufw deny 22/tcp
sudo ufw status

# ======================
# FLATPAK AND FLATHUB CONFIGURATION
# ======================
echo "🌐 Configuring Flatpak and Flathub..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install additional flatpak package
flatpak install -y flathub net.nokyan.Resources

# ======================
# GAMING AND PRODUCTIVITY APPS INSTALLATION
# ======================
echo "🎮 Installing productivity and gaming apps..."
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub com.heroicgameslauncher.hgl
flatpak install -y flathub com.discordapp.Discord
flatpak install -y flathub org.telegram.desktop
sudo apt install -y steam

# ======================
# LAZYVIM SETUP
# ======================
echo "🛠️ Installing LazyVim starter config..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
nvim --headless "+Lazy! sync" +qa || echo "Neovim setup skipped if nvim not installed."

# ======================
# GNOME EXTENSION MANAGER
# ======================
echo "📋 Installing Extension Manager..."
flatpak install -y flathub com.mattjakeman.ExtensionManager

# ======================
# GNOME DASH SETTINGS
# ======================
echo "🔧 Setting GNOME Dash behavior..."
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'

# ======================
# BACKUP TOOLS INSTALLATION
# ======================
echo "📦 Installing Timeshift..."
sudo apt install -y timeshift

# ======================
# VIRTUALIZATION TOOLS INSTALLATION
# ======================
echo "💻 Installing KVM, Virt-Manager..."
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG kvm $(whoami)

# ======================
# DOCKER INSTALLATION
# ======================
echo "🐳 Installing Docker CE..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# ======================
# DATABASE TOOLS INSTALLATION
# ======================
echo "🛢️ Installing MySQL, Workbench, pgAdmin4, DBeaver..."
sudo apt install -y mysql-server mysql-workbench
sudo apt install -y pgadmin4

# Install PostgreSQL and psql client
echo "🐘 Installing PostgreSQL and psql..."
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql

flatpak install -y flathub io.dbeaver.DBeaverCommunity

# ======================
# SPOTIFY INSTALLATION
# ======================
echo "🎵 Installing Spotify..."
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt update
sudo apt install -y spotify-client

# ======================
# SPICETIFY INSTALLATION
# ======================
echo "🎶 Installing Spicetify..."
curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh
sudo chmod a+wr /usr/share/spotify
sudo chmod a+wr /usr/share/spotify/Apps
spicetify backup apply

# ======================
# POWER MANAGEMENT TOOLS
# ======================
echo "🔋 Installing TLP and preload..."
sudo apt install -y tlp tlp-rdw preload
sudo systemctl enable tlp
sudo systemctl start tlp

# ======================
# AWS CLI INSTALLATION
# ======================
echo "☁️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# ======================
# POSTMAN INSTALLATION
# ======================
echo "📬 Installing Postman manually..."
POSTMAN_DIR="/opt/Postman"
sudo mkdir -p $POSTMAN_DIR
curl -L https://dl.pstmn.io/download/latest/linux64 -o postman.tar.gz
sudo tar -xzf postman.tar.gz -C $POSTMAN_DIR --strip-components=1
rm postman.tar.gz
sudo ln -s /opt/Postman/Postman /usr/bin/postman
cat <<EOF | sudo tee /usr/share/applications/postman.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOF

# ======================
# NVM AND NODE INSTALLATION
# ======================
echo "🛠️ Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts

# ======================
# MAILSY INSTALLATION
# ======================
echo "📨 Installing Mailsy..."
npm install mailsy -g

# ======================
# RUST AND PARQUET-CLI INSTALLATION
# ======================
echo "🦀 Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

echo "🪵 Installing Parquet CLI..."
cargo install parquet-cli

# ======================
# ZSH AND OH MY ZSH INSTALLATION
# ======================
echo "💻 Installing Zsh and Oh My Zsh..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "🌟 Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

echo "🛠️ Setting Zsh as default shell..."
chsh -s $(which zsh)

# ======================
# ZSH AND OH MY ZSH INSTALLATION
# ======================
echo "💻 Installing Zsh and Oh My Zsh..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "🌟 Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

echo "🛠️ Setting Zsh as default shell..."
chsh -s $(which zsh)

# ======================
# ZSHRC CUSTOMIZATION
# ======================
echo "⚙️ Adding custom configurations to .zshrc..."

cat << 'EOF' >> ~/.zshrc

# ======================
# Middle Mouse Scroll Settings
# ======================
xinput set-prop 9 "libinput Scroll Method Enabled" 0 0 1

# ======================
# ZSH Keybindings
# ======================
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# ======================
# Git Aliases
# ======================
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push -u origin main"
alias gs="git status"

# ======================
# Other Aliases
# ======================
alias c="clear"

# ======================
# Custom Functions
# ======================
copyclip() {
    if [ -z "\$1" ]; then
        echo "Usage: copyclip <filename>"
        return 1
    fi
    cat "\$1" | xclip -selection clipboard
}
EOF

echo "✅ .zshrc customization done!"

# (Optional) Reload zshrc
echo "🔄 Reloading .zshrc..."
source ~/.zshrc || echo "⚠️ Please run 'source ~/.zshrc' manually if this fails."

# ======================
# PYSpark SETUP
# ======================
echo "🔥 Setting up PySpark..."

# Install Java (required for Spark)
sudo apt install -y openjdk-11-jdk

# Download Apache Spark
wget https://dlcdn.apache.org/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz
tar -xvf spark-3.5.5-bin-hadoop3.tgz
sudo mv spark-3.5.5-bin-hadoop3.tgz /opt/spark

# Set up environment variables
echo "export SPARK_HOME=/opt/spark" >>~/.zshrc
echo "export PATH=\$PATH:/opt/spark/bin" >>~/.zshrc
echo "export PYSPARK_PYTHON=python3" >>~/.zshrc
source ~/.zshrc

echo "✅ PySpark setup completed!"

# ======================
# FINAL MESSAGE
# ======================
echo "✅ All installations complete!"
echo "🔄 Please reboot your machine to apply all group/user changes (Docker, KVM, Zsh, etc.)"


#!/bin/bash

# Exit on error
set -e

echo "Setting up dnf..."
printf "%s" "
max_parallel_downloads=10
countme=false
" | sudo tee -a /etc/dnf/dnf.conf

echo "🔄 Updating system..."
sudo dnf update -y

echo "📦 Enabling RPM Fusion repositories..."
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"$(rpm -E %fedora)".noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"$(rpm -E %fedora)".noarch.rpm
sudo dnf groupupdate core -y

echo "🎥 Enabling OpenH264 codec..."
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

echo "🔄 Replacing ffmpeg-free with full ffmpeg..."
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y

echo "🎶 Updating multimedia group without weak dependencies..."
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y

echo "🛠️ Installing Git and Zsh..."
sudo dnf install git zsh -y

echo "⚙️ Setting Zsh as default shell..."
chsh -s $(which zsh)

echo "💡 Preparing Zsh plugins..."
touch ~/.zshrc
mkdir -p ~/.zsh/plugins

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ~/.zsh/plugins/zsh-completions

echo "📜 Updating .zshrc with plugin configuration..."
cat << 'EOF' >> ~/.zshrc

# Plugin Paths
fpath+=~/.zsh/plugins/zsh-completions

# Load Plugins
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
autoload -Uz compinit && compinit
EOF

echo "🔤 Installing FiraCode Nerd Font..."
mkdir -p ~/.local/share/fonts
wget -O ~/.local/share/fonts/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
unzip -o ~/.local/share/fonts/FiraCode.zip -d ~/.local/share/fonts/FiraCode
fc-cache -fv

echo "🚀 Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

echo "🎨 Applying Catppuccin Powerline Starship preset..."
mkdir -p ~/.config
starship preset catppuccin-powerline -o ~/.config/starship.toml
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

echo "🧩 Adding Flathub repository..."
sudo flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "📦 Adding Terra repository..."
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release -y

echo "🎨 Installing Kvantum and Orchis KDE theme..."
sudo dnf install kvantum -y
cd ~
git clone https://github.com/vinceliuice/Orchis-kde.git
cd Orchis-kde
./install.sh

echo "🎨 Installing Tela Icon Theme system-wide..."
cd ~
git clone https://github.com/vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme

# Install system-wide to /usr/share/icons
sudo ./install.sh -d /usr/share/icons

# Rebuild KDE appearance cache
kbuildsycoca5

echo "Installing vm tools..."
sudo dnf install @virtualization -y
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo usermod -a -G libvirt $(whoami)

echo "Installing other stuff..."
sudo dnf install distrobox podman docker -y

echo "Do you want nvidia drivers? [y/n]"
read -r nvidia
case "$nvidia" in
	y|Y)
		sudo dnf install kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia libva-utils vdpauinfo -y;
	*)
		echo "Skipping nvidia install..."
esac

echo "Upgrading system..."
sudo dnf upgrade -y

echo "Open grub config "/etc/default/grub" and add "nvidia-drm.modeset=1" to "GRUB_CMDLINE_LINUX" line and then do "sudo grub2-mkconfig -o /boot/grub2/grub.cfg""

echo "🔁 Reloading Zsh configuration..."
exec zsh

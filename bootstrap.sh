#!/bin/bash

VSCODE_OS="darwin-universal"

# ------
# Colors
# ------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'

function echo_green {
    MESSAGE=$1
    echo -e "${GREEN}${MESSAGE}${NOCOLOR}"
}

function echo_red {
    MESSAGE=$1
    echo -e "${RED}${MESSAGE}${NOCOLOR}"
}

function install_macos_app {
    APP_NAME=$1
    
    
}

function install_vscode {
    VSCODE_OS=${1:-"darwin-universal"}
    if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
        temp_dir=$(mktemp -d)
        app_temp_dir=$temp_dir/app/
        curl --silent -L -o $temp_dir/vscode.zip "https://code.visualstudio.com/sha/download?build=stable&os=${VSCODE_OS}"
        extract=$(unzip $temp_dir/vscode.zip -d $app_temp_dir)
        cp -Rf "$app_temp_dir/app/Visual Studio Code.app" /Applications/
    else
        echo "Visual Studio Code already installed"
    fi
}

function install_zsh {
    if test ! $(which zsh); then
        brew install zsh
        chsh -s /usr/local/bin/zsh
    else
        echo "Already installed"
    fi
}

function install_oh_my_zsh {
    if [[ ! -d "~/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Already installed"
    fi
}

function install_p10k_zsh_theme {
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    else
        echo "ZSH theme P10K already installed"
    fi
}

function install_asdf {
    ASDF_DIR="$HOME/.asdf"
    ASDF_COMPLETIONS="$ASDF_DIR/completions"
    
    if test ! $(which adfs); then
        mkdir -p $ASDF_DIR
        mkdir -p $ASDF_COMPLETIONS
    else
        echo "ASDF already installed"
    fi
}

function install_brew {
    if test ! $(which brew); then
        export HOMEBREW_BREW_GIT_REMOTE="..."  # put your Git mirror of Homebrew/brew here
        export HOMEBREW_CORE_GIT_REMOTE="..."  # put your Git mirror of Homebrew/homebrew-core here
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        brew update
    else
        echo "Already installed"
    fi
}

function install_brew_package {
    PACKAGE_NAME=$1
    if test ! $(which $PACKAGE_NAME); then
        brew install $PACKAGE_NAME
    else
        echo "Brew $PACKAGE_NAME package already installed"
    fi
}

function install_linuxify {
    CURRENT_DIR=$PWD
    if [[ ! -f "$HOME/.linuxify" ]]; then
        TEMP_DIR=$(mktemp -d)
        cd $TEMP_DIR
        git clone https://github.com/fabiomaia/linuxify.git
        cd linuxify/
        chmod +x linuxify
        ./linuxify install
        cd $CURRENT_DIR
    else
        echo "Linuxify already installed"
    fi
}

function create_folder {
    FOLDER=$1
    [[ ! -d "$FOLDER" ]] && mkdir $FOLDER
}

echo "#######################"
echo "## Install utilities ##"
echo "#######################"
echo "-- XCode Command Line Tools --"
xcode-select --install
echo "-- Brew --"
install_brew
echo "-- Brew packages --"
BREW_PACKAGES=(
    autoconf
    amazon-ecs-cli
    automake
    gmp
    coreutils
    findutils
    pyenv
    jq
    git
    tmux
    wget
    tfenv
    tgenv
)
brew install ${BREW_PACKAGES[@]}
echo "-- Brew cleanup --"
brew cleanup
rm -f -r /Library/Caches/Homebrew/*
echo "-- ASDF --"
install_asdf
echo "-- ZSH --"
install_zsh
echo "-- OhMyZSH --"
install_oh_my_zsh
echo "-- P10K ZSH THEME --"
install_p10k_zsh_theme
echo "-- ZSH Config --"
cp configs/.zshrc ~/.zshrc
echo "-- Linuxify --"
install_linuxify
echo ""
echo "##########"
echo "## ASDF ##"
echo "##########"
echo "-- Install Python --"
asdf plugin add python
asdf install python 3.9.2
asdf global python 3.9.2

echo "###########"
echo "## Python #"
echo "###########"
echo "-- Python Packages --"
PYTHON_PACKAGES="""
ansible
boto3
awscli
flake8
pre-commit
virtualenv
virtualenvwrapper
"""
for python_package in $PYTHON_PACKAGES;
do
    pip3 install $python_package
done
echo "##########"
echo "## APPS ##"
echo "##########"
echo "-- VSCode --"
VSCODE_OS="darwin-universal"
install_vscode $VSCODE_OS

echo "########################"
echo "## OS X Configuration ##"
echo "########################"

## FINDER

# show library
chflags nohidden ~/Library

# show lateral toolbar / show in list mode / show path / always show extensions
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string “Nlsv”
defaults write com.apple.finder ShowPathbar -bool true
sudo defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# show the home folder by default
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# don't create .DS_STORE file
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

## CREATE
FOLDERS="""
~/git
~/scripts
~/experiments
"""
echo "Creating folder structure..."

for folder in $FOLDER;
do
    create_folder $folder
done
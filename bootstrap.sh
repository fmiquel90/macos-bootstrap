#!/bin/bash

source APPS_VERSION

function install_vscode {
    VSCODE_OS=${1:-"darwin-universal"}
    if [[ ! -d "/Applications/Visual Studio Code.app" ]]; then
        temp_dir=$(mktemp -d)
        app_temp_dir=$temp_dir/app
        curl --silent -L -o $temp_dir/vscode.zip "https://code.visualstudio.com/sha/download?build=stable&os=${VSCODE_OS}"
        extract=$(unzip $temp_dir/vscode.zip -d $app_temp_dir)
        cp -Rf "$app_temp_dir/Visual Studio Code.app" /Applications/
    else
        echo "Visual Studio Code already installed"
    fi
}

function install_keeweb {
	KEEWEB_ARCH=${1:-"amd64"}
	KEEWEB_VERSION=${2:-"1.18.7"}
    if [[ ! -d "/Applications/KeeWeb.app" ]]; then
        temp_dir=$(mktemp -d)
        app_temp_dir=$temp_dir/app/
        curl --silent -L -o $temp_dir/keeweb.dmg "https://github.com/keeweb/keeweb/releases/download/v${KEEWEB_VERSION}/KeeWeb-${KEEWEB_VERSION}.mac.${KEEWEB_ARCH}.dmg"
  		hdiutil attach -quiet $temp_dir/keeweb.dmg
        cp -Rf "/Volumes/KeeWeb/KeeWeb.app" /Applications/
        hdiutil detach "/Volumes/KeeWeb"
    else
        echo "KeeWeb already installed"
    fi
}

function install_menu_meters {
    temp_dir=$(mktemp -d)
    curl --silent -L -o $temp_dir/menumeters.zip "https://github.com/emcrisostomo/MenuMeters/releases/download/1.9.8.1%2Bemc/MenuMeters-1.9.8.1+emc.dmg"
    hdiutil attach -quiet $temp_dir/MenuMeters-1.9.8.1+emc.dmg
    installer -pkg /Volumes/MenuMeters/MenuMeters.pkg -target CurrentUserHomeDirectory
    hdiutil detach /Volumes/MenuMeters
}

function install_zsh {
    if test ! $(which zsh); then
        brew install zsh
        chsh -s /usr/local/bin/zsh
    else
        echo "ZSH already installed"
    fi
}

function install_oh_my_zsh {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "OhMyZSH already installed"
    fi
}

function install_p10k_zsh_theme {
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    else
        echo "ZSH theme P10K already installed"
    fi
}

function install_asdf {
    ASDF_DIR="$HOME/.asdf"
    ASDF_COMPLETIONS="$ASDF_DIR/completions"
    
    if test ! $(which asdf); then
        mkdir -p $ASDF_DIR
        mkdir -p $ASDF_COMPLETIONS
        git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v${ASDF_VERSION}
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
)
brew install ${BREW_PACKAGES[@]}
echo "-- Brew Cask --"
BREW_CASKS="""
	slack
	spotify
	sublime-text
"""
for cask in $BREW_CASKS;
do
	brew install --cask $cask
done
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
export ASDF_DIR="$HOME/.asdf"
export ASDF_COMPLETIONS="$ASDF_DIR/completions"
echo "-- Install Python --"
asdf plugin add python
asdf install python ${PYTHON_VERSION}
asdf global python ${PYTHON_VERSION}
echo "-- Install Terraform / Terraform-docs / Terragrunt --"
asdf plugin add terraform
asdf install terraform ${TERRAFORM_VERSION}
asdf plugin add terraform-docs
asdf install terraform-docs ${TERRAFORM_DOCS_VERSION}
asdf plugin add terragrunt
asdf install terragrunt ${TERRAGRUNT_VERSION}
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
echo ""
echo "##########"
echo "## APPS ##"
echo "##########"
echo "-- Menu Meters --"
install_menu_meters
echo "-- KeeWeb --"
install_keeweb ${KEEWEB_ARCH} ${KEEWEB_VERSION}
echo "-- VSCode --"
install_vscode $VSCODE_VERSION
VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
echo "-- Install VScode Extensions --"
"$VSCODE_BIN" --install-extension eamodio.gitlens
"$VSCODE_BIN" --install-extension ms-python.python
"$VSCODE_BIN" --install-extension ms-python.vscode-pylance
"$VSCODE_BIN" --install-extension "CoenraadS.bracket-pair-colorizer-2"
"$VSCODE_BIN" --install-extension "wayou.vscode-todo-highlight"
"$VSCODE_BIN" --install-extension "KevinRose.vsc-python-indent"
echo ""
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

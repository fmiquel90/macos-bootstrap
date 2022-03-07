#!/bin/bash

# Default variables
TERRAFORM_VERSION=1.1.6
TERRAFORM_DOCS_VERSION=0.16.0
TERRAGRUNT_VERSION=0.36.1
PYTHON_VERSION=3.9.10
VSCODE_VERSION=darwin-universal
KEEWEB_VERSION=1.18.7
KEEWEB_ARCH=x64 #or arm64
ASDF_VERSION=0.9.0

if [ -f "APPS_VERSION" ];
then
    . APPS_VERSION
fi

install_vscode () {
    VSCODE_OS=${1:-"darwin-universal"}
    if [ ! -d "/Applications/Visual Studio Code.app" ]; then
        temp_dir=$(mktemp -d)
        app_temp_dir=${temp_dir}/app
        curl --silent -L -o "${temp_dir}/vscode.zip" "https://code.visualstudio.com/sha/download?build=stable&os=${VSCODE_OS}.zip"
        unzip "${temp_dir}/vscode.zip" -d "${app_temp_dir}"
        cp -Rf "${app_temp_dir}/Visual Studio Code.app" /Applications/
    else
        echo "Visual Studio Code already installed"
    fi
}

install_keeweb () {
	KEEWEB_ARCH=${1:-"amd64"}
	KEEWEB_VERSION=${2:-"1.18.7"}
    if [ ! -d "/Applications/KeeWeb.app" ]; then
        temp_dir=$(mktemp -d)
        app_temp_dir=${temp_dir}/app/
        curl --silent -L -o "${temp_dir}/keeweb.dmg" "https://github.com/keeweb/keeweb/releases/download/v${KEEWEB_VERSION}/KeeWeb-${KEEWEB_VERSION}.mac.${KEEWEB_ARCH}.dmg"
  		hdiutil attach -quiet "${temp_dir}/keeweb.dmg"
        cp -Rf "/Volumes/KeeWeb/KeeWeb.app" /Applications/
        hdiutil detach "/Volumes/KeeWeb"
    else
        echo "KeeWeb already installed"
    fi
}

install_menu_meters () {
    temp_dir=$(mktemp -d)
    curl --silent -L -o "${temp_dir}/menumeters.zip" "https://github.com/emcrisostomo/MenuMeters/releases/download/1.9.8.1%2Bemc/MenuMeters-1.9.8.1+emc.dmg"
    hdiutil attach -quiet "${temp_dir}/menumeters.zip"
    installer -pkg /Volumes/MenuMeters/MenuMeters.pkg -target CurrentUserHomeDirectory
    hdiutil detach /Volumes/MenuMeters
}

install_zsh () {
    if test ! "$(command -v zsh || true)"; then
        brew install zsh
        chsh -s /usr/local/bin/zsh
    else
        echo "ZSH already installed"
    fi
}

install_oh_my_zsh () {
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh || true)"
    else
        echo "OhMyZSH already installed"
    fi
}

install_p10k_zsh_theme () {
    if [ ! -d "${HOME}/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}/powerlevel10k"
        # Configuration
        cp configs/.p10k.zsh "${HOME}"
        # Fonts
        FONTS_URL="""
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
        https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
        """
        for font_url in ${FONTS_URL};
        do
            (cd /Library/Fonts && curl --silent -L "${font_url}")
        done
        echo "Don't forget to configure 'MesloLGS NF' in your terminal"
    else
        echo "ZSH theme P10K already installed"
    fi
}

install_asdf () {
    ASDF_DIR="${HOME}/.asdf"
    ASDF_COMPLETIONS="${ASDF_DIR}/completions"
    CHECK_CMD=$(command -v asdf)

    if [ -z "${CHECK_CMD}" ]; then
        git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" --branch "v${ASDF_VERSION}"
        mkdir -p "${ASDF_COMPLETIONS}"
    else
        echo "ASDF already installed"
    fi
}

install_brew () {
    if test ! "$(command -v brew || true)"; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh || true)"
        brew update
    else
        echo "Already installed"
    fi
}

install_brew_package () {
    PACKAGE_NAME=$1
    if test ! "$(command -v "${PACKAGE_NAME}" || true)"; then
        brew install "${PACKAGE_NAME}"
    else
        echo "Brew ${PACKAGE_NAME} package already installed"
    fi
}

install_linuxify () {
    CURRENT_DIR=${PWD}
    if [ ! -f "${HOME}/.linuxify" ]; then
        TEMP_DIR=$(mktemp -d)
        cd "${TEMP_DIR}" || exit
        git clone https://github.com/fabiomaia/linuxify.git
        cd linuxify/ || exit
        chmod +x linuxify
        ./linuxify install
        cd "${CURRENT_DIR}" || exit
    else
        echo "Linuxify already installed"
    fi
}

create_folder () {
    FOLDER=$1
    [ ! -d "${FOLDER}" ] && mkdir "${FOLDER}"
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
    shellcheck
)
brew install "${BREW_PACKAGES[@]}"
echo "-- Brew Cask --"
BREW_CASKS="""
	slack
	spotify
	sublime-text
"""
for cask in ${BREW_CASKS};
do
	brew install --cask "${cask}"
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
export ASDF_DIR="${HOME}/.asdf"
export ASDF_COMPLETIONS="${ASDF_DIR}/completions"
echo "-- Install Python --"
"${ASDF_DIR}/bin/asdf" plugin add python
"${ASDF_DIR}/bin/asdf" install python "${PYTHON_VERSION}"
"${ASDF_DIR}/bin/asdf" global python "${PYTHON_VERSION}"
echo "-- Install Terraform / Terraform-docs / Terragrunt --"
"${ASDF_DIR}/bin/asdf" plugin add terraform
"${ASDF_DIR}/bin/asdf" install terraform "${TERRAFORM_VERSION}"
"${ASDF_DIR}/bin/asdf" global terraform "${TERRAFORM_VERSION}"
"${ASDF_DIR}/bin/asdf" plugin add terraform-docs
"${ASDF_DIR}/bin/asdf" install terraform-docs "${TERRAFORM_DOCS_VERSION}"
"${ASDF_DIR}/bin/asdf" global terraform-docs "${TERRAFORM_DOCS_VERSION}"
"${ASDF_DIR}/bin/asdf" plugin add terragrunt
"${ASDF_DIR}/bin/asdf" install terragrunt "${TERRAGRUNT_VERSION}"
"${ASDF_DIR}/bin/asdf" global terragrunt "${TERRAGRUNT_VERSION}"
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
for python_package in ${PYTHON_PACKAGES};
do
    pip3 install "${python_package}"
done
echo ""
echo "##########"
echo "## APPS ##"
echo "##########"
echo "-- Menu Meters --"
install_menu_meters
echo "-- KeeWeb --"
install_keeweb "${KEEWEB_ARCH}" "${KEEWEB_VERSION}"
echo "-- VSCode --"
install_vscode "${VSCODE_VERSION}"
VSCODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
echo "-- Install VScode Extensions --"
"${VSCODE_BIN}" --install-extension eamodio.gitlens
"${VSCODE_BIN}" --install-extension ms-python.python
"${VSCODE_BIN}" --install-extension ms-python.vscode-pylance
"${VSCODE_BIN}" --install-extension "CoenraadS.bracket-pair-colorizer-2"
"${VSCODE_BIN}" --install-extension "wayou.vscode-todo-highlight"
"${VSCODE_BIN}" --install-extension "KevinRose.vsc-python-indent"
"${VSCODE_BIN}" --install-extension "tumido.cron-explained"
"${VSCODE_BIN}" --install-extension "fnando.linter"

echo ""
echo "########################"
echo "## OS X Configuration ##"
echo "########################"

## FINDER

# show library
chflags nohidden ~/Library

# show lateral toolbar / show in list mode / show path / always show extensions
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
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
${HOME}/git
${HOME}/scripts
${HOME}/experiments
"""
echo "Creating folder structure..."

for folder in ${FOLDERS};
do
    create_folder "${folder}"
done

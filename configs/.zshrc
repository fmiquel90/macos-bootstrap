#ZSH_THEME="powerlevel10k/powerlevel10k"

. "${HOME}/powerlevel10k/powerlevel10k.zsh-theme"

# zsh completion workaround
autoload bashcompinit
autoload -Uz compinit
bashcompinit
compinit

# If you come from bash you might have to change your $PATH. ############
export PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin:${PATH}"

# ALIAS
alias ll='ls -ali'
alias myip='curl http://api.ipify.org'

# Ansible OSX Fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# LINUXIFY
. "${HOME}/.linuxify"

# ASDF
export ASDF_DIR="${HOME}/.asdf"
export ASDF_COMPLETIONS="${ASDF_DIR}/completions"
. ${ASDF_DIR}/asdf.sh
. ${ASDF_DIR}/completions/asdf.bash

# Visual Studio Code
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:${PATH}"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[ ! -f ~/.p10k.zsh ] || . "${HOME}/.p10k.zsh"
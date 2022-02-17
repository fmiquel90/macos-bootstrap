ZSH_THEME="powerlevel10k/powerlevel10k"

# If you come from bash you might have to change your $PATH. ############
export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

# ALIAS
alias ll='ls -ali'
alias myip='curl http://api.ipify.org'

# Ansible OSX Fix
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# LINUXIFY
. $HOME/.linuxify

# ASDF
export ASDF_DIR="$HOME/.asdf"
export ASDF_COMPLETIONS="$ASDF_DIR/completions"
. $ASDF_DIR/libexec/asdf.sh
. $ASDF_DIR/etc/bash_completion.d/asdf.bash
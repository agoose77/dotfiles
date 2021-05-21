# Load pyenv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'register-python-argcomplete pipx > zhook.zsh' pick="zhook.zsh" nocompile'!' \
    atpull'%atclone' \
    id-as"pipx" \
    https://gist.github.com/agoose77/0a3f6c4527272ad06afd1a0788104280/raw

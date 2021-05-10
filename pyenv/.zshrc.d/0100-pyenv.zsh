# Load pyenv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'cat <(pyenv init -) <(pyenv virtualenv-init -) > zhook.zsh' pick="zhook.zsh" nocompile'!' \
    atpull'%atclone' \
    id-as"pyenv" \
    https://gist.github.com/agoose77/0a3f6c4527272ad06afd1a0788104280/raw

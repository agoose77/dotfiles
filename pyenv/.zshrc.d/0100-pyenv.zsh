# Load pyenv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'cat <(pyenv init - --no-rehash) <(pyenv virtualenv-init -) > zhook.zsh' pick="zhook.zsh" nocompile'!' \
    atpull'%atclone' \
    id-as"pyenv" \
    zdharma/null

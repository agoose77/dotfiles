# Silence direnv
export DIRENV_LOG_FORMAT=
# Load direnv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'direnv hook zsh > zhook.zsh' pick="zhook.zsh" nocompile'!' \
    atpull'%atclone' \
    id-as"direnv" \
    zdharma/null

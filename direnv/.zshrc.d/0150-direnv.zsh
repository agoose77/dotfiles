# Silence direnv
export DIRENV_LOG_FORMAT=
# Load direnv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'direnv hook zsh > zhook.zsh' pick="zhook.zsh" nocompile'!' \
    atpull'%atclone' \
    id-as"direnv" \
    https://gist.github.com/agoose77/0a3f6c4527272ad06afd1a0788104280/raw

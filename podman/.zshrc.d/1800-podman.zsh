# Load pyenv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'podman completion zsh > _podman' pick="_podman" nocompile'!' \
    atpull'%atclone' \
    id-as"podman" \
    zdharma/null

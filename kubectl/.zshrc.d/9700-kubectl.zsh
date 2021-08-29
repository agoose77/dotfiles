# Load kubectl hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'kubectl completion zsh > _kubectl' pick="_kubectl" nocompile'!' \
    atpull'%atclone' \
    id-as"kubectl" \
    zdharma/null

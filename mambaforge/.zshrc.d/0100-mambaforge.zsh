# Load pyenv hook by compiling a different file to the no-op URL
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atclone'conda shell.zsh hook conda.zsh' \
    nocompile'!' \
    pick"conda.zsh" \
    atpull'%atclone' \
    esc/conda-zsh-completion

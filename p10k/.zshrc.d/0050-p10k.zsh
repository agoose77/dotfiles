export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Load shell
zinit lucid light-mode for \
    depth=1 lucid atload'[[ ! -f ~/.p10k.zsh ]] && true || source ~/.p10k.zsh; _p9k_precmd' nocd romkatv/powerlevel10k

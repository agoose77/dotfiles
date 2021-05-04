export ZSH_AUTOSUGGEST_USE_ASYNC=1 
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Async plugins
# If ZINIT_WAIT is set (to empty string), this will run blocking
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions

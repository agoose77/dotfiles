# Async plugins
# If ZINIT_WAIT is set (to empty string), this will run blocking
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    from"gh-r" as"program" mv"sd* -> sd" pick"sd*" chmln/sd 

# Silence direnv
export DIRENV_LOG_FORMAT=
zinit ${ZINIT_WAIT-wait} lucid light-mode for \
    from"gh-r" as"program" mv"direnv* -> direnv" \
        atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
        pick"direnv" src="zhook.zsh" direnv/direnv

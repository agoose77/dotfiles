if [[ -d "$HOME/.pyenv" ]]; then
	zinit ${ZINIT_WAIT-wait} lucid for \
	    atload'eval "$(pyenv virtualenv-init - zsh)"' OMZP::pyenv/pyenv.plugin.zsh
fi

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Automatically cd into directories entered as commands
setopt auto_cd

zinit ${ZINIT_WAIT-wait} lucid light-mode for \
	OMZL::completion.zsh \
	OMZL::git.zsh \
	OMZL::grep.zsh \
	OMZL::directories.zsh \
	OMZL::history.zsh \
	OMZL::functions.zsh \
	OMZL::key-bindings.zsh 

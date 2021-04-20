# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If ZINIT_WAIT is set (to empty string), this script will run blocking
WAIT=${ZINIT_WAIT-wait}

# Hide prompt
DEFAULT_USER=`whoami`

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

### End of Zinit's installer chunk

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Automatically cd into directories entered as commands
setopt auto_cd

export ZSH_AUTOSUGGEST_USE_ASYNC=1 
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
    
# Disable config wizard
zinit ice depth=1 lucid atload'[[ ! -f ~/.p10k.zsh ]] && true || source ~/.p10k.zsh; _p9k_precmd' nocd
zinit light romkatv/powerlevel10k
    
# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
	zinit ${WAIT} lucid for \
	    atload'eval "$(pyenv virtualenv-init - zsh)"' OMZP::pyenv/pyenv.plugin.zsh
fi

# Silence direnv
export DIRENV_LOG_FORMAT=

# Non-async plugins
zinit ${WAIT} lucid light-mode for \
    from"gh-r" as"program" mv"**/exa* -> exa" pick"bin/exa" ogham/exa \
    DarrinTisdale/zsh-aliases-exa \
    from"gh-r" as"program" mv"direnv* -> direnv" \
        atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
        pick"direnv" src="zhook.zsh" direnv/direnv \
	OMZL::git.zsh \
	OMZL::completion.zsh \
	OMZL::grep.zsh \
	OMZL::directories.zsh \
	OMZL::history.zsh \
	OMZL::functions.zsh \
	OMZL::key-bindings.zsh \
	OMZP::git/git.plugin.zsh \
	OMZP::tmux/tmux.plugin.zsh \
    OMZP::git-flow/git-flow.plugin.zsh \
    agkozak/zsh-z \
    atinit"zpcompinit; zpcdreplay" zdharma/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" zsh-users/zsh-autosuggestions \
    blockf bobthecow/git-flow-completion \
    _local/jupyter \
    _local/i3 \
    from"gh-r" as"program" mv"sd* -> sd" pick"sd*" chmln/sd \
    as"completion" OMZP::docker/_docker 

# TODO tracking
alias todo='git grep --no-pager  -EI "TODO|FIXME"'
alias td='todo'

# Fd-find alias
alias fd='fdfind'

# Google 
iframe() {
  google-chrome --app="$1"
}

# Wallpapers
. $HOME/.wallpapers/wallpaper.sh

# Change colors for ssh
alias ssh='TERM=xterm-256color ssh'

# Move to trash
alias tt='gio trash'

(( ! ${+functions[p10k]} )) || p10k finalize


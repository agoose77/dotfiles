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
zinit ${WAIT} lucid for \
	OMZ::lib/git.zsh \
	OMZ::lib/completion.zsh \
	OMZ::lib/grep.zsh \
	OMZ::lib/directories.zsh \
	OMZ::lib/history.zsh \
	OMZ::lib/functions.zsh \
	OMZ::lib/key-bindings.zsh \
	OMZ::plugins/git/git.plugin.zsh

zinit ice ${WAIT} lucid 
zinit light agkozak/zsh-z

zinit ice ${WAIT} lucid from"gh-r" as"program" mv"exa* -> exa" pick"exa"
zinit light ogham/exa

zinit ice ${WAIT} lucid
zinit light DarrinTisdale/zsh-aliases-exa

# Micro editor
zinit ice ${WAIT} lucid from"gh-r" as"program" bpick"*linux64*" extract"" mv"micro*/micro -> micro"
zinit load zyedidia/micro

zinit ice ${WAIT} lucid atinit"zpcompinit; zpcdreplay" 
zinit light zdharma/fast-syntax-highlighting

export ZSH_AUTOSUGGEST_USE_ASYNC=1 ZSH_AUTOSUGGEST_STRATEGY=(history completion)
zinit ice ${WAIT} lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions

# Disable config wizard
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
zinit ice depth=1 lucid atload'[[ ! -f ~/.p10k.zsh ]] && true || source ~/.p10k.zsh; _p9k_precmd' nocd
zinit light romkatv/powerlevel10k

# TODO tracking
alias todo='git grep --no-pager  -EI "TODO|FIXME"'
alias td='todo'
zinit ice ${WAIT} lucid
zinit snippet OMZ::plugins/git-flow/git-flow.plugin.zsh
zinit ice ${WAIT} lucid
zinit light bobthecow/git-flow-completion

# Tmux aliases
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'

# direnv
## Silence direnv
export DIRENV_LOG_FORMAT=
zinit ice ${WAIT} lucid from"gh-r" as"program" mv"direnv* -> direnv" \
    atclone'./direnv hook zsh > zhook.zsh' atpull'%atclone' \
    pick"direnv" src="zhook.zsh"
zinit light direnv/direnv

# OMZ take command
function tkdir() {
  mkdir -p $@ && cd ${@:$#}
}

# Jupyter aliases
alias jc="jupyter console"
alias jl="jupyter lab"
alias jle="jupyter labextension"
alias jla="jupyter lab --browser='google-chrome --app=%s'"

# Move to trash
alias tt='gio trash'

# History
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY

# Automatically cd into directories entered as commands
setopt auto_cd

(( ! ${+functions[p10k]} )) || p10k finalize


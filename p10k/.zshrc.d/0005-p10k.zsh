export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load shell (instantly)
zinit lucid light-mode for \
    depth=1 lucid atload'source ~/.p10k.zsh; _p9k_precmd' nocd romkatv/powerlevel10k

# Clear cr_prompt
(( ! ${+functions[p10k]} )) || p10k finalize

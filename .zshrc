###############
#   IMPORTS   #
###############
[[ -f $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

###############
#   EDITORS   #
###############
if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR="nano"
else
  if command -v code >/dev/null 2>&1; then
    export EDITOR='code --wait'
  else
    export EDITOR='nano'
  fi
fi

###############
#     OMZ     #
###############
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="takashiyoshida"
  HYPHEN_INSENSITIVE="true"
  # DISABLE_AUTO_TITLE="true"
  # ENABLE_CORRECTION="true"
  # DISABLE_UNTRACKED_FILES_DIRTY="true"
  # ZSH_CUSTOM=/path/to/new-custom-folder
  plugins=(git extract command-not-found)
  source $ZSH/oh-my-zsh.sh
else
  echo "⚠️  Oh My Zsh not found — skipping OMZ setup"
fi

source ~/.aliases
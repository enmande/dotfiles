###############
#   IMPORTS   #
###############
# rust
[[ -f $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

# nvm  
export NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
  case "$(uname)" in
    Darwin)
      # assume homebrew
      NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"
      NVM_COMPLETION="/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
      ;;
    Linux)
      NVM_SH="$NVM_DIR/nvm.sh"                      
      NVM_COMPLETION="$NVM_DIR/bash_completion"
      ;;
  esac  
  
  # Load NVM if the scripts exist
  [ -s "$NVM_SH" ] && source "$NVM_SH"
  [ -s "$NVM_COMPLETION" ] && source "$NVM_COMPLETION"
fi

###############
#   EDITORS   #
###############
if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR="nano"
else
  if command -v code >/dev/null 2>&1; then
    export EDITOR=(code --wait)
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

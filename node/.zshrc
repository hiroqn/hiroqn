export PATH=$PATH:./node_modules/.bin
export NVM_DIR="$HOME/.nvm"

autoload -U add-zsh-hook

load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    . "$(brew --prefix nvm)/nvm.sh"
    nvm use
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

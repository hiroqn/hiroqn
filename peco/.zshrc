function figlet_peco() {
  font=$(find /usr/local/share/figlet/fonts -name '*.flf' | awk -F / '{print $NF}' | peco)
  figlet -f "$(find /usr/local/share/figlet/fonts -name $font | head -n 1)" $@
}

function history_peco() {
  local tac
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(fc -l -n 1 | eval $tac | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}

function ssh_peco() {
  local host
  host=$(grep -iE '^host' ~/.ssh/config | awk '{print $2}' | peco)
  if [ "$host" != '' ]; then
    ssh $@ $host
  fi
}

zle -N history_peco
bindkey '^r' history_peco

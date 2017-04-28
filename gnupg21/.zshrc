export PATH="/usr/local/opt/gnupg@2.1/bin:$PATH"
gpg-connect-agent /bye
export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
alias gpg=gpg2

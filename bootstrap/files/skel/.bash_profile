#
# ~/.bash_profile
#

# Allow Screen to work with ssh-agent
test $SSH_AUTH_SOCK && ln -sf "$SSH_AUTH_SOCK" "/tmp/ssh-agent-$USER-screen"

[[ -f ~/.bashrc ]] && . ~/.bashrc

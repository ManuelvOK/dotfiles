# danke merkel
# PAM no longer reads ~/.pam_environment (user_readenv defaults to 0).
# Load ~/.config/environment.d instead. It points SSH_AUTH_SOCK at
# gpg-agent, so ssh uses the gpg key.
set -a
eval $(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
set +a

typeset -U path
path=($path ~/dotfiles/scripts)
path=($path ~/dotfiles/scripts/mutt-tools)
path=($path ~/.local/bin)

export XCURSOR_SIZE=24
export RIPGREP_CONFIG_PATH=~/.ripgreprc

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx
fi

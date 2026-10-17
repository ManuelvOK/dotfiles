autoload -Uz add-zsh-hook

setopt interactivecomments
setopt extended_glob

# history
HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=10000000
setopt hist_ignore_all_dups
setopt hist_reduce_blanks hist_verify
setopt share_history extended_history

setopt autocd

# vi mode
MODE_INDICATOR=            # no mode indicator in the prompt, the cursor shows it
MODE_CURSOR_VIINS=beam
MODE_CURSOR_REPLACE=underline
MODE_CURSOR_VICMD=block
MODE_CURSOR_VISUAL=block
source ~/.zsh/zsh-vim-mode/zsh-vim-mode.plugin.zsh
KEYTIMEOUT=1               # switch to normal mode right after Esc

# st sends the key sequences from terminfo (e.g. ^[[3~ for Delete) only in
# keypad application mode, so turn that on while zle reads a line. See the
# st FAQ, "Why doesn't the Del key work in some programs?".
if (( $+terminfo[smkx] && $+terminfo[rmkx] )); then
  autoload -Uz add-zle-hook-widget
  _keypad_on() { echoti smkx }
  _keypad_off() { echoti rmkx }
  add-zle-hook-widget line-init _keypad_on
  add-zle-hook-widget line-finish _keypad_off
fi
bindkey -M vicmd '^[[3~' delete-char

# share_history imports the commands of other shells. Ctrl-R searches them,
# but Up/Down and k/j only walk the commands typed in this shell.
_local_history() {
  zle set-local-history 1
  zle ${WIDGET#local-}
  zle set-local-history 0
}
zle -N local-up-line-or-history _local_history
zle -N local-down-line-or-history _local_history
zle -N local-vi-up-line-or-history _local_history
zle -N local-vi-down-line-or-history _local_history
for _key in '^[[A' '^[OA'; do
  bindkey -M viins $_key local-up-line-or-history
  bindkey -M vicmd $_key local-up-line-or-history
done
for _key in '^[[B' '^[OB'; do
  bindkey -M viins $_key local-down-line-or-history
  bindkey -M vicmd $_key local-down-line-or-history
done
unset _key
bindkey -M vicmd k local-vi-up-line-or-history
bindkey -M vicmd j local-vi-down-line-or-history

autoload -Uz compinit
compinit

# Highlight selection for completion
zstyle ':completion:*' menu select

# compatibility for the terminal to open selected text
_osc7() { printf '\e]7;file://%s\a' "$PWD" }
add-zsh-hook precmd _osc7

#################
# Custom prompt #
#################

# window title: last two directories, plus the command while one runs
_title_dir() { print -Pn '\e]0;%2~\a' }
_title_cmd() { print -Pn '\e]0;%2~: '; print -rn -- "$1"; print -n '\a' }
add-zsh-hook precmd _title_dir
add-zsh-hook preexec _title_cmd

# git line of the prompt, sets ${_gp_line}
source ~/.zsh/git-prompt.zsh
setopt prompt_subst

# st: the mark (\e[ m) for Ctrl+PageUp/PageDown is part of the prompt, so it is
# set after zle clears the line and survives prompt redraws
PROMPT=$'%{\e[ m%}╭ %F{green}%n@%m%f [%*]: %B%F{blue}%4~%f%b ${_gp_line}\n╰ %(!.#.$) '
RPROMPT="%0(?..%F{red}%?%f)"

# colors for ls and grep
eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# some more ls aliases
alias ll='ls -AlFhv'
alias lk='ls -gFhv'
alias la='ls -Av'
alias l='ls -CFv'
alias öö='ll'
alias ö='l'

# alias for determing free space
alias freespace='df -h --type=ext4'

# retry last command with sudo
fuck() { sudo zsh -c "$(fc -ln -1)" }

# sm with black background
alias sm='sm --foreground=white --background=black'

# yogurt
alias yogurt='yay -Syu'

alias cups='sm "631"'

# mutt aliases
alias mutt='mutt_profile normal ifsr'
alias muttt='mutt_profile normal tu-dresden'
alias muttm='mutt_profile normal manuel-kalettka'
alias muttk='mutt_profile normal kernkonzept'
alias muttkm='mutt_profile normal kin-music'

# FIXME: printer Dellifsr is not configured in CUPS anymore and the path
# points to the old home /home/morion
alias höllidruckt='print -u2 "höllidruckt: alias is broken and needs to be fixed (see ~/.zshrc)"; lpr -P Dellifsr -o media=A4 /home/morion/IFSR/hoelli.jpg'

alias autoremove='sudo pacman -Runs $(pacman -Qdtq)'

alias act='source env/bin/activate'

alias forget='echo RELOADAGENT | gpg-connect-agent'

alias jellifin='VNC_PASSWORD=`pass jellifin/vnc` vncviewer 192.168.122.50:30 -DesktopSize=1920x1080 -securitytypes TLSVnc'

export PINENTRY_USER_DATA="curses"
export GPG_TTY=`tty`
# The agent's startup tty (where ssh pinentry shows up) is updated per ssh call
# by the Match exec line in ~/.ssh/config, not here.

# Angular CLI completion. Generating it starts node (~0.3 s), so it is cached
# and only regenerated when ng changes.
_ng_comp=${XDG_CACHE_HOME:-~/.cache}/zsh/ng-completion.zsh
if (( $+commands[ng] )); then
    if [[ ! -s $_ng_comp || ${commands[ng]:A} -nt $_ng_comp ]]; then
        mkdir -p ${_ng_comp:h} && ng completion script >| $_ng_comp
    fi
    source $_ng_comp
fi
unset _ng_comp

if [[ $TERM == st* ]]; then
    export COLORTERM=truecolor
fi

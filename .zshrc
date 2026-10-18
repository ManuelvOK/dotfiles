###########
# Options #
###########

autoload -Uz add-zsh-hook add-zle-hook-widget

setopt interactivecomments
setopt extended_glob
setopt autocd

# directory stack: cd -<Tab> lists recent directories, cd -N jumps back
setopt auto_pushd pushd_ignore_dups pushd_silent
DIRSTACKSIZE=20

# print timing statistics of commands that use more than 10 s of CPU time
# (user + system, so waiting commands like sleep or ssh never show up)
REPORTTIME=10

# no terminal flow control: Ctrl-S no longer freezes the terminal, and
# programs like vim get Ctrl-S and Ctrl-Q as normal keys
[[ -t 0 ]] && stty -ixon

###########
# History #
###########

HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=10000000
setopt hist_ignore_all_dups
setopt hist_reduce_blanks hist_verify
setopt share_history extended_history

###########
# Vi mode #
###########

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

##############
# Completion #
##############

autoload -Uz compinit
compinit

# Highlight selection for completion
zstyle ':completion:*' menu select

# offer newly installed commands without starting a new shell
zstyle ':completion:*' rehash true

# cache slow completions (systemctl units, python/perl modules, modprobe, ...)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-~/.cache}/zsh/zcompcache

# LS_COLORS, used by ls and the completion list
eval "$(dircolors -b)"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# lowercase also matches uppercase ("doc" completes "Documents"), but
# uppercase only matches itself
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# group matches under headings like "-- file --"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

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

###########################
# fzf and autosuggestions #
###########################

# fzf: Ctrl-R searches the history (of all shells), Ctrl-T inserts file paths,
# Alt-C cds into a directory, **<Tab> fuzzy completion. Loaded after the vi
# mode plugin, which binds Ctrl-R as well.
# Ctrl-R lists the newest matches first instead of the best ones. Inside it,
# Ctrl-R toggles to best match first.
FZF_CTRL_R_OPTS='--no-sort'
if [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
fi

# zsh-autosuggestions: grey suggestion from history. Shift-Tab, Right or End
# (l in normal mode) accept it, Ctrl-Tab accepts the next word.
if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  # all widgets exist before the first prompt, so binding them once is enough
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
  # medium grey, readable on the dark background (colour 8 is almost black)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  # these replace the whole line, so they drop the suggestion like the
  # built-in history widgets do
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
    local-up-line-or-history local-down-line-or-history
    local-vi-up-line-or-history local-vi-down-line-or-history
    vi-up-line-or-history vi-down-line-or-history
    fzf-history-widget
  )
  # forward-word accepts the suggestion up to the end of the next word. st
  # sends Ctrl-Tab as CSI 9;5 u (see its config.h), plain Tab otherwise.
  bindkey -M viins '^[[Z' autosuggest-accept
  bindkey -M viins '^[[9;5u' forward-word
  # Shift-Tab used to step back in the completion menu. Keep that there.
  zmodload zsh/complist
  bindkey -M menuselect '^[[Z' reverse-menu-complete
fi

########################
# Terminal integration #
########################

# compatibility for the terminal to open selected text
_osc7() { printf '\e]7;file://%s\a' "$PWD" }
add-zsh-hook precmd _osc7

# window title: last two directories, plus the command while one runs
_title_dir() { print -Pn '\e]0;%2~\a' }
_title_cmd() { print -Pn '\e]0;%2~: '; print -rn -- "$1"; print -n '\a' }
add-zsh-hook precmd _title_dir
add-zsh-hook preexec _title_cmd

##########
# Prompt #
##########

# git line of the prompt, sets ${_gp_line}
source ~/.zsh/git-prompt.zsh
setopt prompt_subst

# st: the mark (\e[ m) for Ctrl+PageUp/PageDown is part of the prompt, so it is
# set after zle clears the line and survives prompt redraws
PROMPT=$'%{\e[ m%}╭ %F{green}%n@%m%f [%*]: %B%F{blue}%4~%f%b ${_gp_line}\n╰ %(!.#.$) '
RPROMPT="%(?..%F{red}%?%f)"

# Transient prompt: once a line is accepted, its prompt in the scrollback
# shrinks to one line with the start time, directory and git status. The st
# mark stays, so Ctrl+PageUp/PageDown still jump between commands.
# ${_gp_short} is referenced, not inserted, so a branch name is never
# evaluated as prompt code.
TRANSIENT_PROMPT=$'%{\e[ m%}%F{244}[%*]%f %B%F{blue}%4~%f%b ${_gp_short:+$_gp_short }%(!.#.$) '
_full_prompt=$PROMPT _full_rprompt=$RPROMPT
_transient_prompt() {
  # the git line without its line break and frame, e.g. "(master|✔)"
  typeset -g _gp_short=${_gp_line#$'\n│'}
  PROMPT=$TRANSIENT_PROMPT RPROMPT=
  zle .reset-prompt
}
_restore_prompt() { PROMPT=$_full_prompt RPROMPT=$_full_rprompt }
add-zle-hook-widget line-finish _transient_prompt
add-zsh-hook precmd _restore_prompt

#######################
# Aliases & functions #
#######################

# colors for ls and grep
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# some more ls aliases
alias ll='ls -AlFhv'
alias lk='ls -gFhv'
alias la='ls -Av'
alias l='ls -CFv'
alias öö='ll'
alias ö='l'

# alias for determining free space
alias freespace='df -h --type=ext4'

# typing a file name as the command opens it with the default application,
# e.g. "paper.pdf" runs "xdg-open paper.pdf". Suffix aliases are case-sensitive,
# so each extension is registered in lower and upper case (cameras write .JPG).
for _ext in pdf png jpg jpeg gif webp svg mp4 mkv webm mp3 flac odt ods docx xlsx; do
  alias -s $_ext=xdg-open ${(U)_ext}=xdg-open
done
unset _ext

# retry last command with sudo
fuck() { sudo zsh -c "$(fc -ln -1)" }

# sm with black background
alias sm='sm --foreground=white --background=black'
alias cups='sm "631"'

# packages
alias yogurt='yay -Syu'
autoremove() {
  local -a orphans=(${(f)"$(pacman -Qdtq)"})
  if (( ! $#orphans )); then
    print "no orphaned packages"
    return 0
  fi
  sudo pacman -Runs $orphans
}

# mutt aliases
alias mutt='mutt_profile normal ifsr'
alias muttt='mutt_profile normal tu-dresden'
alias muttm='mutt_profile normal manuel-kalettka'
alias muttk='mutt_profile normal kernkonzept'
alias muttkm='mutt_profile normal kin-music'

# FIXME: printer Dellifsr is not configured in CUPS anymore and the path
# points to the old home /home/morion
alias höllidruckt='print -u2 "höllidruckt: alias is broken and needs to be fixed (see ~/.zshrc)"; lpr -P Dellifsr -o media=A4 /home/morion/IFSR/hoelli.jpg'

alias act='source env/bin/activate'

alias forget='echo RELOADAGENT | gpg-connect-agent'

alias jellifin='VNC_PASSWORD=`pass jellifin/vnc` vncviewer 192.168.122.50:30 -DesktopSize=1920x1080 -securitytypes TLSVnc'

###############
# Environment #
###############

export PINENTRY_USER_DATA="curses"
export GPG_TTY=`tty`
# The agent's startup tty (where ssh pinentry shows up) is updated per ssh call
# by the Match exec line in ~/.ssh/config, not here.

if [[ $TERM == st* ]]; then
  export COLORTERM=truecolor
fi

#######################
# Syntax highlighting #
#######################

# Must be sourced last: it hooks into zle after everything else that changes
# the command line (see its README).
if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

source ~/.zsh/zsh-git-prompt/zshrc.sh
zstyle ':completion:*:*:git:*' script /usr/share/git/completion/git-completion.zsh
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/morion/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Highlight selection for completion
zstyle ':completion:*' menu select

# Enable prompts
autoload -Uz promptinit
promptinit

# Custom prompt
NL=$'\n'

PROMPT=$'╭ %B\e[00;32m%n@%m%f%b [%*]: %B\e[00;34m%4~%f%b $(git_super_status)${NL}╰ %(!.#.$) '
RPROMPT="%0(?..%F{red}%?%f)"


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -AlFhv'
alias lk='ls -gFhv'
alias la='ls -Av'
alias l='ls -CFv'
alias öö='ll'
alias ö='l'

# plex
alias plex-connect='ssh ssh-login-u42@5.9.86.144 -p 44938 -i .ssh/guro'

# alias for determing free space
alias freespace='df -h --type=ext4'

# retry last command with sudo
alias fuck='sudo $(fc -ln -1)'
#alias fuck='sudo $(history -p \!\!)'

# sm with black background
alias sm='sm --foreground=white --background=black'

# beamer at E069
alias apb-e069='xrandr --output VGA1 --mode 1400x1050 --right-of LVDS1'

# beamer at E067
alias apb-e067='xrandr --output VGA1 --mode 1280x1024 --right-of LVDS1'

# yogurt
alias yogurt='yay -Syu'

# start samba sevices
alias startsamba='sudo systemctl start smbd && sudo systemctl start nmbd'

# steam sucks...
alias steam='LD_PRELOAD="/usr/$LIB/libstdc++.so.6 /usr/$LIB/libgcc_s.so.1 /usr/$LIB/libxcb.so.1 /usr/$LIB/libgpg-error.so" steam'

alias repair_steam='find ~/.steam/root/ \( -name "libgcc_s.so*" -o -name "libstdc++.so*" -o -name "libxcb.so*" -o -name "libgpg-error.so*" \) -print -delete'

# print fingerprint information to screen
alias fingerprint='sm "Manuel Thieme


info@manuel-thieme.de
manuel@ifsr.de
s0020628@mail.zih.tu-dresden.de
manuelthieme@googlemail.com
manuel.thieme@tu-dresden.de


9128 7DD1 C1CE FB91 3F2B 55D0 4225 2CDA 7AF6 F930
"'

alias cups='sm "631"'

# mutt aliases
alias mutt='mutt_profile normal ifsr'
alias muttt='mutt_profile normal tu-dresden'
alias muttm='mutt_profile normal manuel-thieme'

alias höllidruckt='lpr -P Dellifsr -o media=A4 /home/morion/IFSR/hoelli.jpg'

alias autoremove='sudo pacman -Runs $(pacman -Qdtq)'

alias act='source env/bin/activate'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PINENTRY_USER_DATA="curses"
typeset -U PATH path
path=($path ~/.gem/ruby/2.2.0/bin)
path=($path ~/dotfiles/scripts)
path=($path ~/dotfiles/scripts/mutt-tools)
export GPG_TTY=`tty`
gpg-connect-agent updatestartuptty /bye >/dev/null

# Installs what the dotfiles need and links them into $(HOME), one target per
# area. See README.md.

DOTFILES = $(HOME)/dotfiles

# Areas {{{1
# <AREA>_LINKS are paths relative to the repo, linked to the same path below
# $(HOME). <AREA>_PKGS are installed with pacman, <AREA>_AUR with yay.

ZSH_LINKS = .zshrc .zprofile .zsh
ZSH_PKGS  = zsh fzf zsh-autosuggestions zsh-syntax-highlighting

VIM_LINKS = .vim
VIM_PKGS  = gvim ctags vim-spell-de

GIT_LINKS = .gitconfig
GIT_PKGS  = git git-delta git-lfs

GPG_LINKS = .gnupg .config/environment.d/vars.conf
GPG_PKGS  = gnupg pinentry

# The accounts and the ssh config come from the private submodule. Its
# private.mk links them, see the end of this file.
MAIL_LINKS = .mutt
MAIL_PKGS  = mutt isync w3m colordiff
MAIL_AUR   = mutt-ics

SSH_PKGS = openssh

XSESSION_LINKS = .xinitrc .Xresources \
                 .config/systemd/user/dwm-session.target \
                 .config/systemd/user/redshift.service.d/session.conf \
                 .config/systemd/user/battery-warn.service \
                 .config/systemd/user/keyboard.service \
                 $(wildcard .config/redshift/* .config/dunst/*) \
                 $(wildcard .config/xkb/*/*)
# X, redshift, notifications, and what scripts/ calls for dwm and dwmblocks.
# autorandr's profiles and settings come from the private submodule.
XSESSION_PKGS  = xorg-xinit xorg-xrdb xorg-xrandr xorg-xinput xorg-xkbcomp \
                 xorg-setxkbmap xorg-xset redshift dunst libnotify \
                 brightnessctl playerctl libpulse xss-lock autorandr
XSESSION_AUR   = networkmanager-dmenu-git

RANGER_LINKS = $(wildcard .config/ranger/*)
RANGER_PKGS  = ranger

ZATHURA_LINKS = $(wildcard .config/zathura/*)
ZATHURA_PKGS  = zathura zathura-pdf-mupdf

XDG_LINKS = .config/mimeapps.list $(wildcard .local/share/applications/*)
XDG_PKGS  = xdg-utils sxiv

STALONETRAY_LINKS = .stalonetrayrc
STALONETRAY_PKGS  = stalonetray

ALSA_LINKS = .asoundrc

RIPGREP_LINKS = .ripgreprc
RIPGREP_PKGS  = ripgrep

# jshint itself comes from npm
JSHINT_LINKS = .jshintrc

AREAS = zsh vim git gpg mail ssh xsession ranger zathura xdg stalonetray \
        alsa ripgrep jshint

LINKS = $(ZSH_LINKS) $(VIM_LINKS) $(GIT_LINKS) $(GPG_LINKS) $(MAIL_LINKS) \
        $(XSESSION_LINKS) $(RANGER_LINKS) $(ZATHURA_LINKS) $(XDG_LINKS) \
        $(STALONETRAY_LINKS) $(ALSA_LINKS) $(RIPGREP_LINKS) $(JSHINT_LINKS)

SUCKLESS     = dwm st slock dwmblocks-async
SUCKLESS_DIR = $(HOME)/projects/suckless
SUCKLESS_URL = https://github.com/ManuelvOK

VUNDLEDIR = .vim/bundle/Vundle.vim

.PHONY: all $(AREAS) check clean-links yay-install \
        $(SUCKLESS:%=%-install) $(SUCKLESS:%=%-uninstall)

all: $(AREAS)

# Installs the packages in $(1) that are missing. pacman -T needs no root and
# prints only the ones that are not installed, so sudo asks only when needed.
define install
	@missing=$$(pacman -T $(1)); \
	[ -z "$$missing" ] || sudo pacman -S --needed $$missing
endef

define install-aur
	@missing=$$(pacman -T $(1)); \
	[ -z "$$missing" ] || yay -S --needed $$missing
endef

zsh: $(ZSH_LINKS:%=$(HOME)/%)
	$(call install,$(ZSH_PKGS))
	@# compare the name only, the login shell may be /bin/zsh or /usr/bin/zsh
	@shell=$$(getent passwd $$(id -un) | cut -d: -f7); \
	[ "$${shell##*/}" = zsh ] || chsh -s /usr/bin/zsh

vim: $(VIM_LINKS:%=$(HOME)/%) | $(VUNDLEDIR)
	$(call install,$(VIM_PKGS))
	vim +PluginUpdate +PluginClean +qa

git: $(GIT_LINKS:%=$(HOME)/%)
	$(call install,$(GIT_PKGS))

gpg: $(GPG_LINKS:%=$(HOME)/%)
	$(call install,$(GPG_PKGS))
	chmod 700 $(DOTFILES)/.gnupg

mail: gpg $(MAIL_LINKS:%=$(HOME)/%) | /usr/bin/yay
	$(call install,$(MAIL_PKGS))
	$(call install-aur,$(MAIL_AUR))

ssh: gpg
	$(call install,$(SSH_PKGS))

xsession: $(XSESSION_LINKS:%=$(HOME)/%) \
          /usr/local/bin/dwm /usr/local/bin/st /usr/local/bin/slock \
          /usr/local/bin/dwmblocks | /usr/bin/yay
	$(call install,$(XSESSION_PKGS))
	$(call install-aur,$(XSESSION_AUR))

ranger: $(RANGER_LINKS:%=$(HOME)/%)
	$(call install,$(RANGER_PKGS))

zathura: $(ZATHURA_LINKS:%=$(HOME)/%)
	$(call install,$(ZATHURA_PKGS))

# PDFs go to zathura, code to vim in st (from xsession), mailto: to mutt
xdg: zathura $(XDG_LINKS:%=$(HOME)/%)
	$(call install,$(XDG_PKGS))

stalonetray: $(STALONETRAY_LINKS:%=$(HOME)/%)
	$(call install,$(STALONETRAY_PKGS))

alsa: $(ALSA_LINKS:%=$(HOME)/%)

ripgrep: $(RIPGREP_LINKS:%=$(HOME)/%)
	$(call install,$(RIPGREP_PKGS))

jshint: $(JSHINT_LINKS:%=$(HOME)/%)

# Linking {{{1
# .local is linked file by file, like .config
TOP_LINKS    = $(filter-out .config/% .local/%, $(LINKS))
CONFIG_LINKS = $(filter .config/% .local/%, $(LINKS))

$(TOP_LINKS:%=$(HOME)/%): $(HOME)/%:
	ln -s $(DOTFILES)/$* $@

# ~/.config used to be a link to the repo. Linking into it would write into
# the repo itself.
$(CONFIG_LINKS:%=$(HOME)/%): $(HOME)/%:
	@[ ! -L $(HOME)/.config ] || \
	  { echo "~/.config is a link, it must be a directory" >&2; exit 1; }
	mkdir -p $(@D)
	ln -s $(DOTFILES)/$* $@

# Checking {{{1
# Everything in the repo that should be linked, independent of the areas
# above. A file that no area links shows up as not linked.
IGNORE    = . .. .git .gitmodules .gitignore_global .config .local .claude
ALL_TOP   = $(filter-out $(IGNORE), $(wildcard .*))
# Only tracked files. The wildcard skips deletions not yet committed.
ALL_CONFIG = $(wildcard $(shell git -C $(DOTFILES) ls-files .config .local))

# Links that point into the repo but whose target is gone. ~/.local is too
# big to search as a whole, only its directories with links are searched.
DANGLING = { find $(HOME) -maxdepth 1 -xtype l -lname '$(DOTFILES)/*'; \
             find $(HOME)/.config/ -xtype l -lname '$(DOTFILES)/*'; \
             find $(HOME)/.local/share/applications/ -maxdepth 1 -xtype l \
               -lname '$(DOTFILES)/*'; }

# Reports files that are not linked, e.g. because a program saved a config
# by replacing the link with a new file, and dangling links.
check:
	@for f in $(ALL_TOP) $(ALL_CONFIG); do \
	  [ "$$(readlink $(HOME)/$$f)" = "$(DOTFILES)/$$f" ] || \
	    echo "not linked: ~/$$f"; \
	done
	@for f in $(PRIVATE_LINKS); do \
	  [ "$$(readlink $(HOME)/$$f)" = "$(DOTFILES)/private/$$f" ] || \
	    echo "not linked: ~/$$f"; \
	done
	@$(DANGLING) | sed 's/^/dangling: /'

clean-links:
	$(DANGLING) | xargs -r rm -v

# Building {{{1
$(VUNDLEDIR):
	git clone https://github.com/VundleVim/Vundle.vim.git $@

yay-install: /usr/bin/yay

/usr/bin/yay:
	cd /tmp && { [ -d yay ] || git clone https://aur.archlinux.org/yay.git; }
	cd /tmp/yay && makepkg -si

# dwm, st, slock and dwmblocks-async are built from my forks and installed to
# /usr/local. An existing clone is only rebuilt. The install lines call make
# directly, because make -n would run them for real with $(MAKE).
$(SUCKLESS_DIR)/%:
	git clone $(SUCKLESS_URL)/$*.git $@

$(SUCKLESS:%=%-install): %-install: | $(SUCKLESS_DIR)/%
	$(MAKE) -C $(SUCKLESS_DIR)/$*
	sudo make -C $(SUCKLESS_DIR)/$* install

$(SUCKLESS:%=%-uninstall): %-uninstall:
	sudo make -C $(SUCKLESS_DIR)/$* uninstall

# xsession only needs the binaries. Installing again is up to <name>-install.
/usr/local/bin/dwm:       ; $(MAKE) dwm-install
/usr/local/bin/st:        ; $(MAKE) st-install
/usr/local/bin/slock:     ; $(MAKE) slock-install
/usr/local/bin/dwmblocks: ; $(MAKE) dwmblocks-async-install

# Private {{{1
# Adds the private links to mail, ssh and xsession and sets PRIVATE_LINKS.
# Without the submodule, those areas only install their packages.
-include $(DOTFILES)/private/private.mk

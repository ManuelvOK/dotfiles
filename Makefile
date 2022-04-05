IGNORE = .git .gitmodules
FILES = $(filter-out $(IGNORE), $(wildcard .*) $(patsubst private/%,%,$(wildcard private/.*)))
LINKS = $(FILES:%=~/%)

BUNDLEDIR = .vim/bundle
VUNDLEDIR = $(BUNDLEDIR)/Vundle.vim

all: $(LINKS) vim st-install dwm-install slstatus-install

links: $(LINKS)

.PHONY: all vim st-install st-uninstall dwm-install dwm-uninstall slstatus-install slstatus-uninstall yay-install gnupg mutt-private

# TODO: switch to ~ before executing and use vpath
~/.%:
	if [ -f "$(HOME)/dotfiles/.$*" ]; then \
		ln -s ~/dotfiles/.$* $@ ; \
	elif [ -f "$(HOME)/dotfiles/private/.$*" ]; then \
		ln -s ~/dotfiles/private/.$* $@ ; \
	fi; \
	if [ -d "$(HOME)/dotfiles/private/.$*" ]; then \
		ln -s ~/dotfiles/private/.$*/* ~/.$*/; \
	fi

~/.gnupg: gnupg

vim: $(VUNDLEDIR) ~/.vim
	vim +PluginUpdate +PluginClean +qa
	@# PluginUpdate updates the timestamp of $(BUNDLEDIR), thus it is newer
	@# than $(VUNDLEDIR). Hence, make wants to clone vundle again during the
	@# next execution, leading to a git error!
	@# The hack below circumvents this.
	@# Note: it also makes it unnecessary to list $(VUNDLEDIR) as an
	@# order-only prerequisite, though it actually is one.
	touch $(VUNDLEDIR)
	cd ~/.vim && ./gen_stl_tags.sh

gnupg:
	chmod 700 .gnupg

$(VUNDLEDIR): $(BUNDLEDIR)
	git clone https://github.com/gmarik/Vundle.vim.git $@

$(BUNDLEDIR):
	mkdir $@

st-install: /usr/bin/st

/usr/bin/st:
	(cd /tmp && [ -d st ] || git clone https://github.com/manuelthieme/st.git)
	(cd /tmp/st; makepkg -fis)

st-uninstall:
	sudo pacman -Runs st-patched

dwm-install: /usr/bin/dwm

/usr/bin/dwm:
	(cd /tmp && [ -d dwm ] || git clone https://github.com/manuelthieme/dwm.git)
	(cd /tmp/dwm; makepkg -fis)

dwm-uninstall:
	sudo pacman -Runs dwm-patched

slstatus-install: /usr/bin/slstatus

/usr/bin/slstatus:
	(cd /tmp && [ -d slstatus ] || git clone https://github.com/manuelthieme/slstatus.git)
	(cd /tmp/slstatus; makepkg -fis)

slstatus-uninstall:
	sudo pacman -Runs slstatus-patched

yay-install: /bin/yay

/bin/yay:
	(cd /tmp && [ -d yay ] || git clone https://aur.archlinux.org/yay.git)
	(cd /tmp/yay && makepkg -si)

PRIVATE_MUTT_LINKS = $(HOME)/.mutt/accounts $(HOME)/.mutt/common/private_colors \
                     $(HOME)/.mutt/aliases $(HOME)/.mutt/foldertypes

mutt-private: $(PRIVATE_MUTT_LINKS)

$(PRIVATE_MUTT_LINKS): $(HOME)/.mutt/%: $(HOME)/dotfiles/private/.mutt/% | $(HOME)/.mutt
	ln -s $< $@

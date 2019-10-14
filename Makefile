IGNORE = .git
FILES = $(filter-out $(IGNORE), $(wildcard .*))
LINKS = $(FILES:%=~/%)

BUNDLEDIR = .vim/bundle
VUNDLEDIR = $(BUNDLEDIR)/Vundle.vim

ST_PACKAGE = st-git
ST_FILES = /usr/bin/st /usr/share/doc/st-git/README /usr/share/licenses/st-git/LICENSE /usr/share/man/man1/st.1.gz
ST_AUR_REPO = https://aur.archlinux.org/st-git.git

DWM_PACKAGE = dwm-git
DWM_FILES = /usr/bin/dwm /usr/share/doc/dwm-git/README /usr/share/licenses/dwm-git/LICENSE /usr/share/man/man1/dwm.1.gz
DWM_AUR_REPO = https://aur.archlinux.org/dwm-git.git

all: $(LINKS) vim st-install dwm-install

.PHONY: all st-install

# TODO: switch to ~ before executing and use vpath
~/.%:
	ln -s ~/dotfiles/.$* $@
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

st-install: $(ST_FILES)

$(ST_FILES): st-pkgbuild.diff st-font-and-colors.diff
	(cd /tmp && [ -d $(ST_PACKAGE) ] || git clone $(ST_AUR_REPO))
	cp st-pkgbuild.diff st-font-and-colors.diff /tmp/$(ST_PACKAGE)
	(cd /tmp/$(ST_PACKAGE) && git apply st-pkgbuild.diff; makepkg -fis)

st-uninstall:
	sudo pacman -Runs $(ST_PACKAGE)

dwm-install: $(DWM_FILES)

$(DWM_FILES): dwm-pkgbuild.diff dwm-config.def.h.diff
	(cd /tmp && [ -d $(DWM_PACKAGE) ] || git clone $(DWM_AUR_REPO))
	cp dwm-pkgbuild.diff dwm-config.def.h.diff /tmp/$(DWM_PACKAGE)
	(cd /tmp/$(DWM_PACKAGE) && git apply dwm-pkgbuild.diff; makepkg -fis)

dwm-uninstall:
	sudo pacman -Runs $(DWM_PACKAGE)

slstatus-install: /bin/slstatus

/bin/slstatus: yay-install
	yay -S slstatus-git

yay-install: /bin/yay

/bin/yay:
	(cd /tmp && [ -d yay ] || git clone https://aur.archlinux.org/yay.git)
	(cd /tmp/yay && makepkg -si)


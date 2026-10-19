# dotfiles

These are my dotfiles. I use this repository as a personal backup and for
synchronization between my machines.

## What's in here

| Path                             | What                                                           |
|----------------------------------|----------------------------------------------------------------|
| `.zshrc`, `.zprofile`, `.zsh/`   | zsh, with a cheatsheet of its features in `.zsh/cheatsheet.md` |
| `.vim/`                          | vim, plugins via Vundle                                        |
| `.gitconfig`                     | git, with delta as pager                                       |
| `.gnupg/`                        | GnuPG. gpg-agent also serves as ssh agent                      |
| `.mutt/`, `scripts/mutt-tools`   | neomutt with one profile per account, mbsync for syncing       |
| `.xinitrc`, `.Xresources`        | X session: dwm, dwmblocks, st, slock                           |
| `.config/`                       | dunst, ranger, redshift, zathura, environment.d, systemd,      |
|                                  | default applications (`mimeapps.list`)                         |
| `.local/share/applications/`     | `vim-st.desktop`: vim in st as default application             |
| `scripts/`                       | helpers called by dwm and dwmblocks (volume, media, …)         |
| `private/`                       | private submodule: mail accounts, aliases, mbsync, ssh config  |

## Setup

```sh
git clone --recursive https://github.com/ManuelvOK/dotfiles ~/dotfiles
cd ~/dotfiles
make
```

`make` sets up everything. Each area also has its own target, which installs
the packages the area needs and links its files. `make zsh` touches nothing
from the mail setup. sudo only asks when a package is actually missing.

| Target        | Links                                                     | Also                                                     |
|---------------|-----------------------------------------------------------|----------------------------------------------------------|
| `zsh`         | `.zshrc`, `.zprofile`, `.zsh`                             | makes zsh the login shell                                |
| `vim`         | `.vim`                                                    | installs Vundle and updates the plugins                  |
| `git`         | `.gitconfig`                                              |                                                          |
| `gpg`         | `.gnupg`, `.config/environment.d/vars.conf`               |                                                          |
| `mail`        | `.mutt`, `.mbsyncrc` and mutt accounts                    | needs `gpg`                                              |
| `ssh`         | `.ssh/config`                                             | needs `gpg`, which is the ssh agent                      |
| `xsession`    | `.xinitrc`, `.Xresources`, systemd units, redshift, dunst | builds dwm, st, slock and dwmblocks-async, needs yay     |
| `ranger`      | `.config/ranger`                                          |                                                          |
| `zathura`     | `.config/zathura`                                         |                                                          |
| `xdg`         | `mimeapps.list`, `vim-st.desktop`                         | PDFs to zathura, images to sxiv, code to vim in st       |
| `stalonetray` | `.stalonetrayrc`                                          |                                                          |
| `alsa`        | `.asoundrc`                                               |                                                          |
| `ripgrep`     | `.ripgreprc`                                              | `.zprofile` points `RIPGREP_CONFIG_PATH` at it           |
| `jshint`      | `.jshintrc`                                               | jshint itself comes from npm                             |

`private` is a private repository. Its `private.mk` is included by the
Makefile and links the private files of `mail` and `ssh`. Without access to
it, the clone of that submodule fails and those two areas only install their
packages. Everything else works. Its own README covers its files.

| Other target            | Does                                                                         |
|-------------------------|------------------------------------------------------------------------------|
| `make check`            | lists repo files that are not linked, and dangling links                     |
| `make clean-links`      | removes dangling links that point into the repo                              |
| `make yay-install`      | installs yay from the AUR                                                    |
| `make <name>-install`   | clones my fork of dwm, st, slock or dwmblocks-async to `~/projects/suckless` |
|                         | (if needed), builds it and installs it to `/usr/local`                       |
| `make <name>-uninstall` | uninstalls it again                                                          |

A new file in the repo has to be added to the `<AREA>_LINKS` of its area in
the Makefile (or, in `private`, to `private.mk`). Until then, `make check`
lists it as not linked.

## How linking works

- Top-level dotfiles and directories (`.zshrc`, `.vim`, `.gnupg`, …) are
  linked as a whole.
- `~/.config` and `~/.local` are real directories. The files below `.config`
  and `.local` are linked one by one. Everything else programs keep there
  stays out of the repo.
- Some programs save their config by writing a new file over the link. The
  file then silently stops being the one in the repo. `make check` lists those.
- After deleting a file from the repo, `make clean-links` removes its link.

### Migrating from a linked `~/.config`

Older checkouts linked `~/.config` itself to the repo, so every program kept
its state inside the repo. The Makefile refuses to link into `.config` as
long as `~/.config` is such a link. To migrate:

1. Pull. If git refuses because untracked files under `.config` would be
   overwritten (e.g. `environment.d/vars.conf`), move those aside, pull, and
   compare them with the versions from the repo.
2. Close programs that write to `~/.config`, e.g. Spotify, Signal and the
   browser. Staying in X is fine.
3. Move everything git does not track out of the repo, in zsh (in bash, `.*`
   also matches `.` and `..`):

   ```sh
   unlink ~/.config && mkdir ~/.config      # unlink only removes a link
   cd ~/dotfiles/.config
   keep=($(git ls-files . | cut -d/ -f1 | sort -u))
   for e in * .*; do
     (( ${keep[(Ie)$e]} )) || mv -- "$e" ~/.config/
   done
   ls -A                                    # only the tracked directories
   ```

   It is all one filesystem, so `mv` only renames and is instant.
4. Link the files, then check:

   ```sh
   cd ~/dotfiles && make gpg xsession ranger zathura xdg && make check
   ```

   These are the areas with files in `.config`. Plain `make` also works, but
   runs every area.
5. Test:
   - `systemctl --user daemon-reload`, then `systemctl --user status
     dwm-session.target redshift battery-warn`: all active.
   - On another tty, log in: `echo $SSH_AUTH_SOCK` points at gpg-agent and
     `ssh-add -l` lists the key, so `environment.d` works.

To undo it, move everything from `~/.config` back into `~/dotfiles/.config`,
then `rmdir ~/.config && ln -s ~/dotfiles/.config ~/.config`.

## Git identity

`.gitconfig` sets my private identity. Repos below `~/work/` include
`~/.gitconfig-work`, which only exists on the work machine and is not part of
this repo. It holds a `[user]` block with the work identity. Without the file,
git skips the include.

A single repo can also set its own identity with `git config user.email …`
inside it.

## X session

`.zprofile` runs `startx` on tty1. `.xinitrc` then

1. hands `DISPLAY` to systemd and D-Bus (`/etc/X11/xinit/xinitrc.d`),
2. starts `dwm-session.target`, which binds `graphical-session.target`,
3. starts dwmblocks and xss-lock, which locks the screen with slock after 10
   minutes without input and before suspend,
4. runs dwm and stops the target again when dwm quits.

xss-lock runs from `.xinitrc` and not as a user service, because it finds its
logind session through its own PID.

Services that belong to the X session are pulled in by `dwm-session.target`
and are `PartOf=graphical-session.target`. See `.config/systemd/user/`.

| Service        | Does                                                                                        |
|----------------|---------------------------------------------------------------------------------------------|
| `redshift`     | warmer colours in the evening                                                               |
| `battery-warn` | notifies when the laptop is docked but not charging, runs on battery, or the battery is low |

`scripts/battery-warn` recognises the dock by its USB ID. A new dock goes into
`DOCKS` at the top of the script.

## Contribution

These are MY dotfiles. I use this repository as a PERSONAL backup and for
synchronization between MY machines.

If you have a great addition in mind, consider creating your own dotfiles
repository and I will steal it from you. If you are really kind, open an issue
and point me to your solution.

No pull requests. I will test everything locally and tweak with it a bit, then
I'll commit it once I'm content.

# zsh cheatsheet

## Line editing (zsh-vim-mode)

| Keys                                    | Effect                                                                       |
|-----------------------------------------|------------------------------------------------------------------------------|
| `Alt-.`                                 | insert the last argument of the previous command, press again for older ones |
| `Ctrl-Q`                                | park the current line, run another command, then the parked line comes back  |
| `Ctrl-X Ctrl-E`, `Ctrl-V` (normal mode) | edit the command line in `$EDITOR`                                           |
| `H` (normal mode)                       | help for the command under the cursor (`man`)                                |
| `U` (normal mode)                       | redo                                                                         |
| `ys` / `cs` / `ds` (normal mode)        | add / change / delete surrounding quotes or brackets, e.g. `cs"'`            |
| `ci"`, `da(`, ...                       | text objects for quotes and brackets                                         |

## Transient prompt

After pressing Enter, the full prompt of that line shrinks to one line in the
scrollback:

```
[1:46:09] ~/projects/linux (master|✔) $ make -j16
...
╭ kin@CarlElias [1:52:30]: ~/projects/linux
│(master|✔)
╰ $
```

The time is when the command started. The git status (only inside a
repository) is the one at that moment. The st mark stays, so Ctrl+PageUp/Down
still jump between commands. The exit code (right prompt) is only shown on the
current prompt.

## Directory stack

Every `cd` pushes the previous directory onto a stack (up to 20 entries,
no duplicates).

| Keys / command | Effect                               |
|----------------|--------------------------------------|
| `cd -<Tab>`    | list recent directories and pick one |
| `cd -2`        | jump to entry 2 of the stack         |
| `cd -`         | back to the previous directory       |
| `dirs -v`      | show the stack with its numbers      |

## REPORTTIME

Commands that use more than 10 s of **CPU time** (user + system) print a
timing line afterwards:

```
make  42.10s user 3.20s system 380% cpu 11.9 total
```

Elapsed time does not count: `sleep`, `ssh` or downloads never show up, no
matter how long they take.

## Completion

| Feature          | Example                                                                                                     |
|------------------|-------------------------------------------------------------------------------------------------------------|
| case-insensitive | `cd doc<Tab>` completes `Documents`                                                                         |
| smart case       | uppercase only matches itself: `Doc` won't match `doc`                                                      |
| colours          | file lists use the same colours as `ls` (`LS_COLORS`)                                                       |
| group headings   | matches are grouped under `-- option --`, `-- file --`                                                      |
| zsh-completions  | 179 extra completion definitions, nothing to set up                                                         |
| auto-rehash      | newly installed commands complete right away, no new shell needed                                           |
| completion cache | slow lists are cached in `~/.cache/zsh/zcompcache`: `systemctl` units, Python/Perl modules, `modprobe`, ... |

## fzf

| Keys      | Effect                                                             |
|-----------|--------------------------------------------------------------------|
| `Ctrl-R`  | fuzzy search the history of **all** shells, newest match first     |
| `Ctrl-T`  | pick files/directories and insert their paths at the cursor        |
| `Alt-C`   | pick a directory and `cd` into it                                  |
| `**<Tab>` | fuzzy completion, e.g. `vim **<Tab>`, `cd **<Tab>`, `kill **<Tab>` |

`Ctrl-R` matches fuzzily: the letters of the query in order, gaps allowed.
So `xkb` finds `setxkbmap eu`, but also lines that only contain x, k and b
somewhere. Every further letter thins them out. Inside the list:

| Keys / query | Effect                                                    |
|--------------|-----------------------------------------------------------|
| `Ctrl-R`     | toggle between newest first and best match first          |
| `'term`      | match `term` exactly, as one piece                        |
| `^term`      | line starts with `term`                                   |
| `term$`      | line ends with `term`                                     |
| `!term`      | line does not contain `term`                              |
| `Tab`        | mark multiple entries                                     |
| `Enter`      | put the selection on the command line                     |

`Ctrl-R` replaces zsh's own incremental history search.

## zsh-autosuggestions

A grey suggestion from history appears behind the cursor while typing.

| Keys                           | Effect                                                    |
|--------------------------------|-----------------------------------------------------------|
| `Shift-Tab`, `End` or `Right`  | accept the whole suggestion                               |
| `l` (normal mode)              | accept the whole suggestion                               |
| `Ctrl-Tab`                     | accept the next word (needs st to send its own Ctrl-Tab)  |
| `Ctrl-Right` or `Alt-Right`    | accept the next word                                      |
| keep typing                    | ignore it                                                 |

In the completion menu, `Shift-Tab` still steps back.

Suggestions come from the shared history, so they can include commands typed
in other shells. `Up`/`Down` and `k`/`j` still only walk this shell's
history and clear the suggestion.

## zsh-syntax-highlighting

| Colour     | Meaning                                   |
|------------|-------------------------------------------|
| green      | valid command, alias, function or builtin |
| red, bold  | unknown command                           |
| yellow     | quoted string                             |
| underlined | existing file or directory                |

## Suffix aliases (open files by name)

Typing a file name as the command opens it with the default application:

```
paper.pdf        # runs: xdg-open paper.pdf
./scans/a.JPG    # upper case works too
my\ photo.jpg    # escaped spaces work
```

Covered extensions, in lower and upper case:

| Kind      | Extensions                     |
|-----------|--------------------------------|
| documents | pdf, odt, ods, docx, xlsx      |
| images    | png, jpg, jpeg, gif, webp, svg |
| video     | mp4, mkv, webm                 |
| audio     | mp3, flac                      |

## Limits

| Limit                          | Details                                                                                                                                                             |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `REPORTTIME` is CPU time       | long but idle commands (`sleep`, `ssh`, downloads) are never reported                                                                                               |
| quoted file names don't open   | `"my photo.jpg"` is not expanded: zsh never expands aliases in quoted words. Use `my\ photo.jpg` or Tab completion.                                                 |
| `xdg-open` blocks the terminal | it runs in the foreground, so some viewers keep the terminal busy until they are closed                                                                             |
| `xdg-open` defaults            | which app opens what depends on the xdg configuration (`~/.config/mimeapps.list`)                                                                                   |
| Ctrl-C keeps the full prompt   | lines abandoned with Ctrl-C keep their full prompt in the scrollback (zsh skips the hook there, and a trap-based fix broke vi mode)                                 |
| completion cache scope         | pacman/yay completion doesn't use the cache. `systemctl` rebuilds its cache after a day or when a unit directory changes. `rm -r ~/.cache/zsh/zcompcache` clears it |

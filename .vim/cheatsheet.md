# vim cheatsheet

Everything beyond plain vim. My own mappings and settings from `vimrc`, and
what the plugins add. Plain vim is not covered.

## My mappings

| Keys       | Mode                  | Effect                                                                 | Replaces in plain vim          |
|------------|-----------------------|------------------------------------------------------------------------|--------------------------------|
| `K`        | normal                | break the line at the cursor                                           | `K` (look up keyword in `man`) |
| `<C-K>`    | normal                | NERDTree: open, or reveal the current file in it                       |                                |
| `<F7>`     | normal                | cycle spell language: `en_gb` → `en_us` → `de,en_gb`                   |                                |
| `gb`       | normal                | show `git blame` of the current line                                   |                                |
| `gr`       | normal                | ALE: references of the symbol under the cursor, into the quickfix list | `gr` (virtual replace)         |
| `gd`       | normal, Python        | ALE: go to definition (language server)                                | `gd` (local declaration)       |
| `ga`       | normal, C/C++         | switch between header and source (guillotine)                          | `ga` (show character code)     |
| `gp`       | normal                | LaTeX: show the cursor position in the PDF (mzview)                    | `gp` (put, cursor after)       |
| `i$`, `a$` | operator, visual, TeX | text object for inline maths `$…$`                                     |                                |
| `Q`, `q:`  | normal                | disabled (no Ex mode, no command-line window)                          |                                |

`:call SynGroup()` shows the syntax group under the cursor and what it links
to. Useful when a colour scheme highlights something oddly.

## Settings that differ from plain vim

| Setting                      | Effect                                                                    |
|------------------------------|---------------------------------------------------------------------------|
| `relativenumber` + `number`  | relative line numbers, absolute one on the cursor line                    |
| `nofoldenable`               | folds are computed, but off. `zi` switches folding on                     |
| `clipboard=`                 | yank and put do not touch the system clipboard. Use `"+y` and `"+p`       |
| `noswapfile`, `nobackup`     | no swap or backup files                                                   |
| `expandtab`, `shiftwidth=4`  | spaces, 4 wide. Makefiles keep tabs (`tabstop=8`)                         |
| `ignorecase` + `smartcase`   | search ignores case unless the pattern has an uppercase letter            |
| `wildmode=longest:full,full` | command line completion like zsh                                          |
| `list`                       | trailing spaces shown as `·`                                              |
| `exrc` + `secure`            | a `.vimrc` in the project is sourced (see vim-projectlocal)               |
| `textwidth`                  | git commits 72, Markdown 80, Python and TypeScript 99, Python comments 72 |

## Spelling

Spell checking is on for git commits, Markdown and mails.

| Where                                  | Language                                |
|----------------------------------------|-----------------------------------------|
| git commits, Markdown, everything else | `en_gb`                                 |
| mails                                  | `de,en_gb` (German and English at once) |

| Keys        | Effect                                                        |
|-------------|---------------------------------------------------------------|
| `]s`, `[s`  | next / previous misspelled word                               |
| `z=`        | suggestions for the word under the cursor                     |
| `zg`        | add the word to the list of the first language (`en` or `de`) |
| `2zg`       | add the word to the list of the other language                |
| `zw`, `zug` | mark a word as wrong / undo `zg` or `zw`                      |
| `<F7>`      | cycle `en_gb` → `en_us` → `de,en_gb` for this buffer          |
| `yos`       | toggle spell checking (vim-unimpaired)                        |

The colour of the undercurl says what is wrong:

| Colour  | Group        | Meaning                                           |
|---------|--------------|---------------------------------------------------|
| red     | `SpellBad`   | unknown word                                      |
| cyan    | `SpellLocal` | right word, wrong region, e.g. "color" in `en_gb` |
| blue    | `SpellCap`   | sentence starts lowercase                         |
| magenta | `SpellRare`  | rare word                                         |

To see the colours, open this file and switch through the languages with
`<F7>`. Each language marks the line below in red, cyan and blue:

Colour or color? Did you recieve it? then tell me.

| Language   | Red (bad) | Cyan (other region) | Blue (lowercase start) |
|------------|-----------|---------------------|------------------------|
| `en_gb`    | recieve   | color               | then                   |
| `en_us`    | recieve   | Colour              | then                   |
| `de,en_gb` | recieve   | color               | then                   |

Magenta never shows up: none of the three dictionaries marks a word as rare.
Vim's English dictionary does, but only for Australian and New Zealand
English ("vim" itself, for example).

A file that always needs another language can say so in a modeline, e.g.
`vim: set spelllang=de:` in its last lines.

## Editing

### vim-surround

| Keys               | Effect                                                  |
|--------------------|---------------------------------------------------------|
| `ys{motion}{char}` | surround, e.g. `ysiw)` → `(word)`, `ysiw(` → `( word )` |
| `yss{char}`        | surround the whole line                                 |
| `cs{old}{new}`     | change surrounding, e.g. `cs"'`, `cs'<q>`               |
| `ds{char}`         | delete surrounding, e.g. `ds"`, `dst` (tag)             |
| `S{char}`          | visual mode: surround the selection                     |

### vim-commentary

| Keys          | Effect                                                |
|---------------|-------------------------------------------------------|
| `gcc`         | toggle comment of the line (with count: lines)        |
| `gc{motion}`  | toggle comment over a motion, e.g. `gcap` (paragraph) |
| `gc`          | visual mode: toggle comment of the selection          |
| `gcgc`, `gcu` | uncomment the comment block around the cursor         |

### vim-exchange

| Keys         | Effect                                                               |
|--------------|----------------------------------------------------------------------|
| `cx{motion}` | mark the first text, then again on the second: both swap             |
| `cxx`        | the same for whole lines                                             |
| `X`          | visual mode: the same for the selection. Replaces `X` (delete lines) |
| `cxc`        | forget the marked text                                               |

### vim-abolish

| Keys / command                           | Effect                                                                                                 |
|------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `crs`, `crc`, `crm`, `cru`, `cr-`, `cr.` | change the word under the cursor to snake_case, camelCase, MixedCase, SNAKE_UPPER, dash-case, dot.case |
| `:S/child{,ren}/adult{,s}/g`             | substitute and keep case and variants (`Child` → `Adult`, `children` → `adults`)                       |
| `:Abolish teh the`                       | correct a typo as you type, in all case variants                                                       |

### targets.vim

More and smarter text objects. The plain `i(`, `a"` etc. also search forward
when the cursor is not inside the pair.

| Text object  | Selects                                                                                |
|--------------|----------------------------------------------------------------------------------------|
| `in(`, `il(` | inside the next / last parentheses on the line (also `[`, `{`, `<`, `"`, `'`, `` ` ``) |
| `I(`, `A(`   | inside without surrounding whitespace / around including it                            |
| `i,`, `a,`   | between separators: `, . ; : + - = ~ _ * # / \| \ & $`                                 |
| `ia`, `aa`   | a function argument, with `aa` also its comma                                          |
| `it`, `at`   | tags, as in plain vim, but also forward                                                |

### vim-speeddating

| Keys             | Effect                                                                 |
|------------------|------------------------------------------------------------------------|
| `<C-A>`, `<C-X>` | also increment / decrement dates and times, e.g. `2026-10-18`, `14:30` |
| `d<C-A>`         | set the date or time under the cursor to now                           |

### vim-unimpaired

Pairs of `[` (previous, before, on) and `]` (next, after, off).

| Keys                      | Effect                                               |
|---------------------------|------------------------------------------------------|
| `[b`, `]b`, `[B`, `]B`    | previous / next / first / last buffer                |
| `[q`, `]q`, `[l`, `]l`    | previous / next quickfix / location list entry       |
| `[a`, `]a`, `[t`, `]t`    | previous / next argument / tag                       |
| `[f`, `]f`                | previous / next file in the same directory           |
| `[n`, `]n`                | previous / next merge conflict marker                |
| `[<Space>`, `]<Space>`    | add a blank line above / below                       |
| `[e`, `]e`                | move the line up / down                              |
| `>p`, `<p`, `=p`          | paste linewise with more / less / fixed indentation  |
| `yo{x}`, `[o{x}`, `]o{x}` | toggle / switch on / switch off an option, see below |
| `[x`, `]x`                | XML encode / decode (`[xx` for the line)             |
| `[u`, `]u`                | URL encode / decode                                  |
| `[y`, `]y`                | C string escape / unescape                           |

| `{x}`         | Option                             |
|---------------|------------------------------------|
| `s`           | `spell`                            |
| `w`           | `wrap`                             |
| `n`, `r`      | `number`, `relativenumber`         |
| `l`           | `list`                             |
| `h`           | `hlsearch`                         |
| `i`           | `ignorecase`                       |
| `c`, `u`, `x` | `cursorline`, `cursorcolumn`, both |
| `t`           | `colorcolumn`                      |
| `d`           | `diff` (`:diffthis` / `:diffoff`)  |
| `v`           | `virtualedit`                      |
| `b`           | `background`                       |

### Smaller helpers

| Plugin                     | Effect                                                                                               |
|----------------------------|------------------------------------------------------------------------------------------------------|
| vim-repeat                 | `.` also repeats the mappings of surround, commentary, exchange, abolish, speeddating and unimpaired |
| vim-endwise                | adds `end`, `endif`, `fi`, … after Enter in Lua, vim script, shell, Ruby                             |
| vim-highlightedyank        | the yanked text flashes briefly                                                                      |
| vim-highlight-cursor-words | after 200 ms, all occurrences of the word under the cursor are underlined                            |
| vim-peekaboo               | `"` and `@` in normal mode and `<C-R>` in insert mode show the registers in a sidebar                |

## Files and navigation

### CtrlP

| Keys                        | Effect                                                     |
|-----------------------------|------------------------------------------------------------|
| `<C-P>`                     | fuzzy find files below the project root (`.git` or `tags`) |
| `:CtrlPBuffer`, `:CtrlPMRU` | the same for buffers / recently used files                 |

In the prompt:

| Keys                              | Effect                                                                                                             |
|-----------------------------------|--------------------------------------------------------------------------------------------------------------------|
| `<C-J>`, `<C-K>`                  | down / up in the list                                                                                              |
| `<CR>`, `<C-T>`, `<C-V>`, `<C-X>` | open here / in a tab / vertical split / split                                                                      |
| `<C-F>`, `<C-B>`                  | switch mode: files, buffers, MRU                                                                                   |
| `<C-D>`                           | match the file name only, not the path                                                                             |
| `<C-R>`                           | regex mode                                                                                                         |
| `<C-Z>`, `<C-O>`                  | mark files / open all marked                                                                                       |
| `<C-Y>`                           | create the typed file                                                                                              |
| `<C-I>`                           | rescan the files (my mapping, instead of `<F5>`). Replaces `<Tab>`, which completes directory names in plain CtrlP |

The file list is cached in `~/.cache/ctrlp`, also between sessions. New files
appear only after `<C-I>`.

### NERDTree

`<C-K>` opens it. It closes after opening a file and replaces netrw, so
`:e some/dir` shows NERDTree.

| Keys          | Effect                                                      |
|---------------|-------------------------------------------------------------|
| `o`, `<CR>`   | open file / expand directory                                |
| `t`, `i`, `s` | open in a tab / split / vertical split                      |
| `x`, `X`      | close the parent / all child directories                    |
| `p`, `P`      | go to the parent / root                                     |
| `C`, `u`      | make the node / the parent the root                         |
| `m`           | menu: add, move, copy, delete a file                        |
| `I`           | show hidden files                                           |
| `R`           | refresh                                                     |
| `[c`, `]c`    | previous / next file with git changes (nerdtree-git-plugin) |
| `?`           | help                                                        |

Git status is shown next to each file: modified, staged, untracked, …

### vim-fetch

`file:line:column` works everywhere a file name is expected:

| Example                 | Effect                                      |
|-------------------------|---------------------------------------------|
| `vim src/main.c:42`     | open at line 42                             |
| `:e src/main.c:42:7`    | the same from inside vim, column 7          |
| `gF` on `src/main.c:42` | open the file under the cursor at that line |

`scripts/rgo` builds on this: `rgo pattern` runs `rg` and opens every match
in vim at its line.

### Project path (pathfinder.vim)

When a buffer is opened, `path` is extended by the project root, found by
`compile_commands.json`, `tags` or `.git`. So `:find name<Tab>` and `gf` work
across the whole project.

### Header and source (guillotine.vim)

`ga` or `:ToggleHeaderSource` switches between `foo.c` and `foo.h` (also
`.cpp` / `.hpp`), searched in `path`.

## Code

### ALE (linting, language server)

Linting runs only on save, not while typing, entering or leaving insert mode.

| Language   | Linters                                         |
|------------|-------------------------------------------------|
| C, C++     | clang, clang-tidy                               |
| Python     | jedi-language-server, mypy, flake8, pycodestyle |
| JavaScript | jshint, jscs                                    |
| TypeScript | tsserver                                        |
| Lua        | luac                                            |
| shell      | shellcheck                                      |
| HTML       | angular                                         |

| Keys / command             | Effect                                                                                                  |
|----------------------------|---------------------------------------------------------------------------------------------------------|
| `gd` (Python)              | go to definition                                                                                        |
| `gr`                       | find references, into the quickfix list (`]q`, `[q`, `:copen`). Needs a language server, so Python only |
| `<C-X><C-O>` (Python)      | completion from the language server                                                                     |
| `:ALELint`                 | lint now                                                                                                |
| `:ALENext`, `:ALEPrevious` | jump to the next / previous problem                                                                     |
| `:ALEDetail`               | full message of the problem under the cursor                                                            |
| `:ALEHover`                | documentation of the symbol under the cursor                                                            |
| `:ALEInfo`                 | which linters run, and why one does not                                                                 |

flake8 also reads `~/.flake8`, if that file exists.

### Completion and tags

| Plugin / command  | Effect                                                                                       |
|-------------------|----------------------------------------------------------------------------------------------|
| OmniCppComplete   | `<C-X><C-O>` completes C++ members from the `tags` file. Not automatically after `.` or `->` |
| `:GenerateTags c` | omnitags.vim generates a `tags` file for the project. Only C is supported                    |
| `:UpdateTags`     | omnitags.vim, C only: update the `tags` file                                                 |

`tags` is searched upwards from the current directory (`tags=tags;/`).

### Python

| Plugin                 | Effect                                                       |
|------------------------|--------------------------------------------------------------|
| vim-python-pep8-indent | indentation as PEP 8 wants it                                |
| python-syntax          | better highlighting (all options on)                         |
| vim-OnSyntaxChange     | `textwidth` is 72 inside comments and docstrings, 99 in code |

## Folding

Folding is off by default (`zi` to switch it on).

| Filetype   | Folds by                                                     |
|------------|--------------------------------------------------------------|
| Python     | classes and functions (SimpylFold), not every indented block |
| YAML       | indentation                                                  |
| JavaScript | syntax                                                       |
| Markdown   | headings                                                     |

FastFold keeps syntax and expression folds fast: they are only recomputed
when saving, with `zuz`, or with the fold commands (`zx`, `za`, `zo`, `zc`, …).

## LaTeX (mzview.vim)

| Keys / command          | Effect                                                     |
|-------------------------|------------------------------------------------------------|
| `gp`, `:SynctexForward` | show the cursor position in the PDF viewer                 |
| `:SpawnViewer [file]`   | open the PDF viewer                                        |
| `:RebuildPDF`           | build with `latexmk -pdf -synctex=1`                       |
| `:UpdateViewer`         | reload the PDF in the viewer                               |
| `i$`, `a$`              | text object for inline maths (my `after/ftplugin/tex.vim`) |

## Syntax only

These plugins only add highlighting:

| Plugin                                           | For                                                                                              |
|--------------------------------------------------|--------------------------------------------------------------------------------------------------|
| vim-syntax-extra                                 | C, bison, flex: operators, delimiters                                                            |
| vim-javascript                                   | JavaScript                                                                                       |
| AnswerSetProgramming-VIM-Syntax-Highlighting     | ASP / clingo. No filetype detection: `:set ft=AnswerSetProgramming`                              |
| wombat256.vim                                    | the colour scheme                                                                                |
| `syntax/l4mods.vim`, `simics.vim`, `objdump.vim` | L4Re `modules.list`, Simics scripts, objdump output. Set the filetype by hand or with a modeline |

## Fun

`:Panzer` inserts a random ASCII-art tank as a comment (panzer.vim).

## Plugin management

| Command          | Effect                                                                            |
|------------------|-----------------------------------------------------------------------------------|
| `make vim`       | install missing plugins, update all, remove unlisted ones, install `vim-spell-de` |
| `:PluginInstall` | install plugins listed in `vimrc` but missing                                     |
| `:PluginUpdate`  | update all plugins                                                                |
| `:PluginClean`   | remove plugins no longer listed                                                   |
| `:PluginList`    | list the configured plugins                                                       |

A project can bring its own `.vimrc` (vim-projectlocal). It is found in the
project root (marked by `compile_commands.json`) and in subdirectories, and
sourced top-down when a file there is opened.

## Known quirks

| Quirk            | Effect                                                                                                                                                                                                |
|------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pathfinder.vim   | upstream prints the path of `compile_commands.json` or `tags` as an error (a leftover `echoerr`). Patched locally in `.vim/bundle`. A plugin update keeps the patch unless upstream changes that file |
| `typescript-vim` | still in `.vim/bundle`, but no longer listed. `make vim` removes it                                                                                                                                   |

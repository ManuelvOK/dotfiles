# Asynchronous git status for the prompt. The prompt only uses ${_gp_line},
# which is either empty or "\n│(<branch><ahead/behind>|<counts>)".
#
# Before each prompt, a pure zsh check decides whether $PWD is inside a git
# work tree, so the git line is there from the start and the prompt never grows
# by a line later. `git status` runs in the background. If it answers within
# a short wait, the prompt is drawn with the result directly. Otherwise a
# placeholder is shown and replaced via `zle reset-prompt` once git is done.
# Inside the same repo the previous status stays visible until then.

zmodload zsh/system zsh/zselect
autoload -Uz add-zsh-hook

typeset -g _gp_line= _gp_root= _gp_fd= _gp_pid=

# hundredths of a second to wait for git before drawing the prompt
typeset -g GIT_PROMPT_WAIT=5

# Sets REPLY to the work tree root containing $PWD, fails outside a repo
_gp_find_root() {
  local dir=$PWD
  while true; do
    if [[ -e $dir/.git ]]; then
      REPLY=$dir
      return 0
    fi
    [[ $dir == / ]] && return 1
    dir=${dir:h}
  done
}

# Sets REPLY to the branch (or ":<short hash>") of the repo at $1, read from HEAD
_gp_head() {
  local gitdir=$1/.git head
  if [[ -f $gitdir ]]; then
    # worktrees and submodules: .git is a file "gitdir: <path>"
    IFS= read -r head < $gitdir || return 1
    gitdir=${head#gitdir: }
    [[ $gitdir == /* ]] || gitdir=$1/$gitdir
  fi
  [[ -r $gitdir/HEAD ]] || return 1
  IFS= read -r head < $gitdir/HEAD || return 1
  if [[ $head == 'ref: refs/heads/'* ]]; then
    REPLY=${head#ref: refs/heads/}
  else
    REPLY=:${head[1,7]}
  fi
}

# Usage: _gp_render <branch> [<behind> <ahead> <staged> <conflicts> <changed> <untracked>]
# With the branch only, the counts are shown as pending.
_gp_render() {
  local s="%B%F{magenta}${1//\%/%%}%f%b"
  if (( $# == 1 )); then
    s+='|%F{242}⋯%f'
  else
    (( $2 )) && s+="↓$2"
    (( $3 )) && s+="↑$3"
    s+='|'
    (( $4 )) && s+="%F{red}●$4%f"
    (( $5 )) && s+="%F{red}✖$5%f"
    (( $6 )) && s+="%F{blue}✚$6%f"
    (( $7 )) && s+='…'
    (( $4 + $5 + $6 + $7 )) || s+='%B%F{green}✔%f%b'
  fi
  _gp_line=$'\n'"│($s)"
}

# Turns the output of `git status --porcelain=v2 --branch` into _gp_line
_gp_parse() {
  local line branch oid
  local -a ab
  local -i behind=0 ahead=0 staged=0 conflicts=0 changed=0 untracked=0
  for line in ${(f)1}; do
    case $line in
      ('# branch.oid '*)  oid=${line#\# branch.oid } ;;
      ('# branch.head '*) branch=${line#\# branch.head } ;;
      ('# branch.ab '*)
        ab=(${=line#\# branch.ab })
        ahead=${ab[1]#+}
        behind=${ab[2]#-}
        ;;
      ([12]' '*)
        # "1 XY ...": X is the index status, Y the work tree status
        [[ $line[3] != . ]] && staged+=1
        [[ $line[4] != . ]] && changed+=1
        ;;
      ('u '*) conflicts+=1 ;;
      ('? '*) untracked+=1 ;;
    esac
  done
  if [[ -z $branch ]]; then
    # git failed, e.g. inside the .git directory itself
    _gp_line=
    return
  fi
  [[ $branch == '(detached)' ]] && branch=:${oid[1,7]}
  _gp_render $branch $behind $ahead $staged $conflicts $changed $untracked
}

# Reads the complete git output from fd $1 and closes it
_gp_receive() {
  local fd=$1 out
  IFS= read -r -d '' -u $fd out
  exec {fd}<&-
  _gp_fd=
  _gp_parse $out
}

# zle -F handler: git finished while the prompt was already shown
_gp_done() {
  zle -F $1
  _gp_receive $1
  zle reset-prompt
}
zle -N _gp_done

# Drops a git job that is still running from the previous prompt
_gp_cancel() {
  [[ -n $_gp_fd ]] || return 0
  zle -F $_gp_fd 2>/dev/null
  exec {_gp_fd}<&-
  _gp_fd=
  kill $_gp_pid 2>/dev/null
  return 0
}

_gp_precmd() {
  local -a reply
  _gp_cancel
  if ! _gp_find_root; then
    _gp_root= _gp_line=
    return 0
  fi
  if [[ $REPLY != $_gp_root || -z $_gp_line ]]; then
    _gp_root=$REPLY
    if _gp_head $_gp_root; then
      _gp_render $REPLY
    else
      _gp_render '?'
    fi
  fi
  # --no-optional-locks: never take index.lock, so this can't collide with
  # git commands typed at the same time
  exec {_gp_fd}< <(exec git --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
  _gp_pid=$sysparams[procsubstpid]
  if zselect -t $GIT_PROMPT_WAIT -r $_gp_fd; then
    _gp_receive $_gp_fd
  else
    zle -F -w $_gp_fd _gp_done
  fi
  return 0
}
add-zsh-hook precmd _gp_precmd

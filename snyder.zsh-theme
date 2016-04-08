local ret_status="%(?:%{$fg[green]%}⨮ :%{$fg_bold[red]%}⨵ )"
PROMPT='%{${ret_status} %{$fg[yellow]%}%c%{$reset_color%} $(git_prompt_info)$reset_color%}  '

function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$fg_bold[green]$(git_commits_ahead)$(git_prompt_behind)$(parse_git_dirty)"
  fi
}
function parse_git_dirty() {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  if [[ -n $STATUS ]]; then
    echo "$fg[yellow]($fg[red]$(current_branch)\uE0A0$fg[yellow])$fg[red]❗️ "
  else
    echo "$fg[yellow]($fg[blue]$(current_branch)\uE0A0$fg[yellow])"
  fi
}
# Gets the number of commits ahead from remote
function git_commits_ahead() {
  if $(echo "$(command git log @{upstream}..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    local COMMITS
    COMMITS=$(command git log @{upstream}..HEAD | grep '^commit' | wc -l | tr -d ' ')
    echo "$COMMITS↑ "
  fi
}
# Outputs if current branch is behind remote
function git_prompt_behind() {
  if [[ -n "$(command git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
}
ZSH_THEME_GIT_PROMPT_BEHIND="$fg_bold[red]⇊ %{$reset_color%}"

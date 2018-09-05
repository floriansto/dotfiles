# vim: ft=zsh
# Format for git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="›"

# Format for parse_git_dirty()
ZSH_THEME_GIT_PROMPT_DIRTY=" $fg[red](*)"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_UNMERGED=" $fg[red]unmerged"
ZSH_THEME_GIT_PROMPT_DELETED=" $fg[red]deleted"
ZSH_THEME_GIT_PROMPT_RENAMED=" $fg[yellow]renamed"
ZSH_THEME_GIT_PROMPT_MODIFIED=" $fg[yellow]modified"
ZSH_THEME_GIT_PROMPT_ADDED=" $fg[green]added"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" $fg[white]untracked"

# Format for git_prompt_ahead()
ZSH_THEME_GIT_PROMPT_AHEAD=" $fg[red](!)"

# Format for git_prompt_long_sha() and git_prompt_short_sha()
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" $fg[white][$fg[yellow]"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="$fg[white]]"
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
local mydate="$FX[bold]$FG[008]%D{%H:%M:%S}$FX[reset]"


if [[ $UID -eq 0 ]]; then
    local user_host='%{$terminfo[bold]$fg[red]%}%n@%m%{$reset_color%}'
elif [[ ! -z $SSH_CONNECTION ]]; then
    local user_host='%{$terminfo[bold]$fg[yellow]%}%n@%m%{$reset_color%}'
else
    local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
fi

local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'
local rvm_ruby=''
if which rvm-prompt &> /dev/null; then
  rvm_ruby='%{$fg[red]%}‹$(rvm-prompt i v g)›%{$reset_color%}'
else
  if which rbenv &> /dev/null; then
    rvm_ruby='%{$fg[red]%}‹$(rbenv version | sed -e "s/ (set.*$//")›%{$reset_color%}'
  fi
fi
local git_info='$fg[blue]$(git_current_branch)$(git_prompt_short_sha)$(git_prompt_status)$(parse_git_dirty)$(git_prompt_ahead)$FX[reset]'

PROMPT="╭─${user_host} ${current_dir} ${rvm_ruby} %{${git_info}%}
╰─%B$%b "
RPS1="${return_code} ${mydate}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"

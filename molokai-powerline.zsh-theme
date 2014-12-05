# vim:ft=zsh ts=2 sw=2 sts=2
# A molokai-ish powerline theme heavily inspired by ys & agnoster
# for best results, change your terminals blue to orange

CURRENT_BG='NONE'
PRIMARY_FG=black

# Characters
SEGMENT_SEPARATOR="⮀"
PLUSMINUS="±"
BRANCH="⭠"
DETACHED="➦"
CROSS="✘"
LIGHTNING="⚡"
GEAR="bg"

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
  else
    print -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    print -n "%{%k%}"
  fi
  print -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`
  prompt_segment magenta default "%{%B%}# %{%F{white}%}%(!.%{%F{yellow}%}.)$user@%m %{%b%}"
}

# Git: branch/detached head, dirty status
prompt_git() {
  local color color2 ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      color=blue
      color2=white
      ref="${ref} $PLUSMINUS"
    else
      color=green
      color2=black
      ref="${ref} "
    fi
    if [[ "${ref/.../}" == "$ref" ]]; then
      ref="$BRANCH $ref"
    else
      ref="$DETACHED ${ref/.../}"
    fi
    prompt_segment $color $color2
    print -Pn "%{%B%} $ref%{%b%}"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment white black '%{%B%} %~ %{%b%}'
}

prompt_second_line() {
  prompt_segment black red "%{%B%}\n$%{%b%}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$GEAR"

  [[ -n "$symbols" ]] && prompt_segment $PRIMARY_FG default "%{%B%} $symbols %{%b%}"
}

## Main prompt
prompt_mp_main() {
  RETVAL=$?
  CURRENT_BG='NONE'
  prompt_context
  prompt_dir
  prompt_git
  prompt_status
  prompt_end
  prompt_second_line
}

prompt_mp_right() {
  print -n "[%{%B%F{magenta}%}"`date +%T`"%{%F{default}%b%}]%{%k%f%}"
}

prompt_mp_precmd() {
  vcs_info
  RPROMPT='%{%f%b%k%}$(prompt_mp_right) '
  PROMPT='%{%f%b%k%}$(prompt_mp_main) '
}

prompt_mp_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  add-zsh-hook precmd prompt_mp_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_mp_setup "$@"

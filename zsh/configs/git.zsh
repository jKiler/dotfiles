compdef g=git
function g {
  if [[ $# -gt 0 ]]; then
    git "$@"
  else
    git status --short --branch
  fi
}

function convc {
  local m="$1: "

  local branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ $branch =~ ([A-Z]+-[0-9]+) ]]; then
    m+="${BASH_REMATCH[1]} "
  fi

  m+="$2"

  git commit -m "$m" && git l -1
}

function gfe {
  convc "feat" "$1"
}

function gfi {
  convc "fix" "$1"
}

function gre {
  convc "refactor" "$1"
}

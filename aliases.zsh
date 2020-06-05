# Things that are technically not aliases
sprunge () {
    cat - | curl -F 'sprunge=<-' http://sprunge.us
}

dn () {
    python -c "import random; print(random.randrange(1, $1 + 1))"
}

yaml2json () {
    ruby -e "require 'yaml'; require 'json'; puts YAML.load(STDIN.read).to_json"
}

json2yaml () {
    ruby -e "require 'yaml'; require 'json'; puts JSON.load(STDIN.read).to_yaml"
}

useaws () {
  # Usage: useaws <profile-name>
  # Exports AWS environment into the current shell
  profile=$1
  for assignment in $(aws-profile -p "$profile" env | grep '^AWS'); do
    export "${assignment?}"
  done
}

clearaws () {
  # Usage: clearaws
  # Clears all set AWS environment variables
  for var in $(env | grep '^AWS' | cut -d= -f1); do
    unset "$var"
  done
}

proceed() {
    if [[ -n "$1" ]]; then
        prompt=$1
    else
        prompt="Proceed?"
    fi
    local confirm
    while [[ -z "$confirm" ]]; do
        1>&2 read -r "confirm?$prompt (yes/no) "
        if [[ "$confirm" != "yes" ]] && [[ "$confirm" != "no" ]]; then
            1>&2 echo "Please answer exactly yes or no (case-sensitive)"
            unset confirm
        fi
    done
    if [[ "$confirm" == "yes" ]]; then
        echo "yes"
    else
        echo "no"
    fi
}

git-purge () {
    non_master_branches=$(git branch | grep -v master)
    echo "This will force delete (git branch -D) all non-master branches"
    if [[ -z "$non_master_branches" ]]; then
        echo "No non-master branches to delete"
        return
    fi
    echo "Branches up for deletion:"
    echo "$non_master_branches"
    if [[ "$(proceed 'Are you sure?')" != "yes" ]]; then
        echo "Aborting due to user input"
    else
        echo $non_master_branches | xargs git branch -D
    fi
}

# Die aliases
for n in $(seq 2 20); do
  alias d$n="dn $n"
done

## Aliases

# Convenience
alias c='cd'
alias k='kubectl'
alias l='ls -lh'
alias la='ls -lha'
alias ll='ls -lh'
alias myip='curl -s icanhazip.com'
alias t='true'
alias ipgrep="rg '([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?'"

# Dangerous
# These aliases are prefixed with a bare read; they require double tapping enter to execute.
alias 'frig!'='read && git commit -a --amend --no-edit && git push -f'

# Common opts
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias pcp='gopass show -c'
alias xclip='xclip -selection clipboard'

# Alternative names
alias loc='tokei'
alias nc='ncat'
alias pass='gopass'
alias vim='nvim'

# Typos
alias sl='ls'
alias ivm='vim'
alias gs='g s'

# Docker
alias centos='docker run -it --rm centos /bin/bash'
alias ubuntu='docker run -it --rm ubuntu /bin/bash'

# OSX
if [[ "$(uname)" == "Darwin" ]]; then
    alias find='gfind'
    alias sed='gsed'
    alias tar='gtar'
    alias ls='gls --color=auto'
fi

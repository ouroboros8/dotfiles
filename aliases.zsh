# Things that are technically not aliases
sprunge () {
    cat - | curl -F 'sprunge=<-' http://sprunge.us
}

dn () {
    python -c "import random; print(random.randrange(1, $1 + 1))"
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

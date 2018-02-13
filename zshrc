#### zsh/ohmyzsh

# Profile zsh start speed
#zmodload zsh/zprof

# path should be a unique array
typeset -aU path

source ~/.dotfiles/antigen/antigen.zsh

antigen bundle git
antigen bundle pip
antigen bundle lein
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle Tarrasch/zsh-autoenv

antigen use oh-my-zsh
antigen theme agnoster

antigen apply


#### z (https://github.com/rupa/z)
export _Z_CMD=j
source ~/.dotfiles/z/z.sh

##### Zsh settings

### Zsh completion help
bindkey '^Xh' _complete_help

### Incremental search
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^F' history-incremental-pattern-search-forward

### Biggest history
export HISTSIZE=9999999999999999 # LONG_MAX (64-bit)
export SAVEHIST=9999999999999999

### Aliases
source ~/.dotfiles/aliases.zsh


#### Environment

## on OSX we need to prefix $path with /usr/local/bin for brew to function properly
if [[ $(uname) == 'Darwin' ]]; then
    path=( /usr/local/bin $path )
fi

## opt to path
path=( $path $HOME/.local/bin )

### gpg-agent SSH support
# Fedora: https://github.com/fedora-infra/ssh-gpg-smartcard-config/blob/master/YubiKey.rst
if [ -f /etc/fedora-release ]; then
    if [ ! -f /run/user/$(id -u)/gpg-agent.env ]; then
        killall gpg-agent;
        eval $(gpg-agent --daemon --enable-ssh-support > /run/user/$(id -u)/gpg-agent.env);
    fi
    . /run/user/$(id -u)/gpg-agent.env
else
    gpg-connect-agent /bye 2>&1 >/dev/null
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

### hub (https://github.com/github/hub) and lab (https://github.com/zaquestion/lab)
# Prefer lab because it's hub-aware
if which lab 2>&1 >/dev/null; then
    alias git=lab
elif which hub 2>&1 >/dev/null; then
    alias git=hub
fi

### Langs

## Python
export VIRTUALENVWRAPPER_PYTHON="/usr/bin/python3"
virtualenvwrapper_path="$(which virtualenvwrapper.sh)"
if [[ -n "$virtualenvwrapper_path" ]]; then
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    export WORKON_HOME=~/.virtualenvs
    source "$virtualenvwrapper_path"
fi

## Go
if go version 2>&1 >/dev/null; then
    GOPATH="$HOME/.local/go"
    mkdir -p $GOPATH
    export GOPATH
    export path=( $path "$GOPATH/bin" )
fi

## Rust
if [ -d "$HOME/.cargo/" ]; then
    export path=( $path "$HOME/.cargo/bin" )
fi

## Ruby
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

## Perl6
if [ -d "$HOME/.perl6/" ]; then
    export path=( $path "$HOME/.perl6/bin" )
fi

## tfenv
if [ -d "$HOME/.tfenv/" ]; then
    export path=( $path "$HOME/.tfenv/bin" )
fi

## Editor
if which nvim >/dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

## Fix VTE issue: https://gnunn1.github.io/tilix-web/manual/vteconfig/
VTE_PROFILE=/etc/profile.d/vte.sh
if [[ -e "$VTE_PROFILE" ]]; then
    source /etc/profile.d/vte.sh
fi

## fzf (https://github.com/junegunn/fzf)
export FZF_DEFAULT_COMMAND='rg --files --hidden -F'
export FZF_DEFAULT_OPTS="--height 25% --border"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## gopass completion
export fpath=( $fpath "$HOME/.local/go/share/zsh/site-functions" )

# Print packages to update
# Requires passwordless sudo:
# <username> ALL=(ALL) NOPASSWD: /usr/bin/pacman
if grep 'Arch Linux' /etc/os-release >/dev/null 2>&1; then
    sudo pacman -Syup --print-format "%n"
fi

#### zsh/ohmyzsh

# Profile zsh start speed
# zmodload zsh/zprof

source ~/.dotfiles/antigen/antigen.zsh

# antigen reset can clear up weird issues which are apparently to do with
# caches not being updated when a bundle updates or something?
# Since it doesn't take perceptibly longer to just clear every time I start a
# shell, that's what I'm doing. ANTIGEN_CACHE=false might also do the trick
# but there are some bugs raised against it
antigen reset >/dev/null 2>&1

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

### hub (https://github.com/github/hub) and lab (https://github.com/zaquestion/lab)
# Prefer lab because it's hub-aware
if which lab >/dev/null 2>&1; then
    alias git=lab
elif which hub >/dev/null 2>&1; then
    alias git=hub
fi

### Environment

## gopass completion
export fpath=( "$HOME/.local/go/share/zsh/site-functions" $fpath )

## tfenv
if [ -d "$HOME/.tfenv/" ]; then
    path=( "$HOME/.tfenv/bin" $path )
fi

## Editor
if which nvim >/dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

## gpg-agent (with SSH support)
# Some nonsense required in Fedora:
# https://github.com/fedora-infra/ssh-gpg-smartcard-config/blob/master/YubiKey.rst
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

## fzf (https://github.com/junegunn/fzf)
export FZF_DEFAULT_COMMAND='rg --hidden --files -F'
export FZF_CTRL_T_COMMAND='rg --hidden --files -F'
export FZF_DEFAULT_OPTS="--height 25% --border"

### Development

## Use GNU tools
# This is at the top because pipenv --completion requires GNU basename
if [[ "$(uname -s)" =~ Darwin ]]; then
    path=( "/usr/local/opt/coreutils/libexec/gnubin" $path )
fi

## Python
# PATH for binaries installed with pip install --user <package>
if [[ "$(uname -s)" =~ Darwin ]]; then
    path=(
      "/Users/StroDa/Library/Python/3.6/bin"
      $path
    )
fi
# virtualenvwrapper
virtualenvwrapper_path="$(which virtualenvwrapper.sh)"
if [[ -f "$virtualenvwrapper_path" ]]; then
    export VIRTUALENVWRAPPER_PYTHON=$(which python3 || which python)
    export WORKON_HOME=~/.virtualenvs
    source "$virtualenvwrapper_path"
fi
# ... and pipenv completion
if which pipenv >/dev/null 2>&1; then
    eval $(pipenv --completion)
fi

## Go
if go version 2>&1 >/dev/null; then
    GOPATH="$HOME/.local/go"
    mkdir -p $GOPATH
    export GOPATH
    path=( "$GOPATH/bin" $path )
fi

## Rust
if [ -d "$HOME/.cargo/" ]; then
    path=( "$HOME/.cargo/bin" $path )

    if which rustup >/dev/null 2>&1; then
        default_toolchain=$(\
            rustup show \
            | grep '(default)' \
            | head -n1 \
            | cut -d' ' -f1 \
        )
        export fpath=(
            "$HOME/.rustup/toolchains/$default_toolchain/share/zsh/site-functions"
            $fpath
        )
    fi
fi

## Perl6
if [ -d "$HOME/.perl6/" ]; then
    path=( "$HOME/.perl6/bin" $path )
fi

## RVM
# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

## Fix VTE issue (for Tilix): https://gnunn1.github.io/tilix-web/manual/vteconfig/
VTE_PROFILE=/etc/profile.d/vte.sh
if [[ -e "$VTE_PROFILE" ]]; then
    source /etc/profile.d/vte.sh
fi

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Scripts in $HOME/.local/bin take precedence:
path=( "$HOME/.local/bin" $path )

# dedupe path array (-U is for unique array)
typeset -aU path
export path

# Co-op SSH helper
helper_path="$HOME/coop/dotfiles/coop_ssh"
if [[ -f "$helper_path" ]]; then
    source "$helper_path"
fi

# Print packages to update
# Requires passwordless sudo:
# <username> ALL=(ALL) NOPASSWD: /usr/bin/pacman
if grep 'Arch Linux' /etc/os-release >/dev/null 2>&1; then
    sudo pacman -Syup --print-format "%n"
fi

alert () {
    echo "\e[1;31m$@\e[0m"
}

check_dotfiles_branch() {
    dotfiles_dir="$HOME/.dotfiles"
    if [[ "$(uname -s)" =~ Darwin ]]; then
        if [[ "$(cd $dotfiles_dir && git branch | grep '^\*' | cut -d' ' -f2)" != "osx" ]]; then
            alert "WARNING: not on osx-specific branch"
            alert "Switch to osx branch and restart the shell"
        fi
    elif [[ "$(uname -s)" =~ Linux ]]; then
        if [[ "$(cd $dotfiles_dir && git branch | grep '^\*' | cut -d' ' -f2)" == "osx" ]]; then
            alert "WARNING: on osx-specific branch, but this appears to be linux"
            alert "Switch to master branch and restart the shell"
        fi
    fi
}

check_dotfiles_branch

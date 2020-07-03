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
antigen bundle lukechilds/zsh-nvm

antigen use oh-my-zsh
antigen theme avit

antigen apply

# In which I wrestle with various dumb OSX things
if [[ "$(uname -s)" =~ Darwin ]]; then

    # /usr/libexec/path_helper is path unhelpful
    path=(
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
    )

    # Use GNU tools not crappy BSD ones
    path=( "/usr/local/opt/coreutils/libexec/gnubin" $path )

    # Add binaries installed with pip install --user <package> to PATH
    path=( "$HOME/Library/Python/3.7/bin" $path )

    # Puppet stuff
    path=( "/opt/puppetlabs/pdk/bin" $path )

fi

#### z (https://github.com/rupa/z)
export _Z_CMD=j
source ~/.dotfiles/z/z.sh

#### source work zshrc if present
if [[ -f "$HOME/.work-dotfiles/zshrc" ]]; then
    source "$HOME/.work-dotfiles/zshrc"
fi

#### Zsh settings

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

### Development

# virtualenvwrapper

whichsoever() {
    # which but don't output and unhelpful error message to stdout on failure
    which $@ >/dev/null 2>&1 && which $@
}

virtualenvwrapper_path="$(which virtualenvwrapper.sh)"
if [[ -f "$virtualenvwrapper_path" ]]; then
    export VIRTUALENVWRAPPER_PYTHON="$(whichsoever python3 || whichsoever python)"
    export WORKON_HOME=~/.virtualenvs
    source "$virtualenvwrapper_path"
fi
# ... and pipenv completion
if which pipenv >/dev/null 2>&1; then
    eval $(pipenv --completion)
fi

## poetry
[[ -d ~/.poetry/bin/ ]] && path=( ~/.poetry/bin/ $path )

## Go
if whichsoever go >/dev/null; then
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

## Jenv
if [ -d "$HOME/.jenv/" ]; then
    export path=( "$HOME/.jenv/bin" $path )
    eval "$(jenv init -)"
fi

# Serverless Framework
serverless_home="/home/dan/.nvm/versions/node/v11.10.0/lib/node_modules/serverless"
if [[ -f "$serverless_home" ]]; then
    source "$serverless_home/node_modules/tabtab/.completions/serverless.zsh"
    source "$serverless_home/node_modules/tabtab/.completions/sls.zsh"
    source "$serverless_home/node_modules/tabtab/.completions/slss.zsh"
fi

## Fix VTE issue (for Tilix): https://gnunn1.github.io/tilix-web/manual/vteconfig/
VTE_PROFILE=/etc/profile.d/vte.sh
if [[ -e "$VTE_PROFILE" ]]; then
    source /etc/profile.d/vte.sh
fi

# FZF
source /usr/local/Cellar/fzf/0.20.0/shell/key-bindings.zsh
source /usr/local/Cellar/fzf/0.20.0/shell/completion.zsh

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
    else
        if [[ "$(cd $dotfiles_dir && git branch | grep '^\*' | cut -d' ' -f2)" == "osx" ]]; then
            alert "WARNING: on osx-specific branch, but this doesn't appears to be osx"
            alert "Switch to master branch and restart the shell"
        fi
    fi
}

check_dotfiles_branch

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

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
which fzf >/dev/null || 2>&1 echo FZF not found
which rg >/dev/null || 2>&1 echo RipGrep not found
export FZF_DEFAULT_COMMAND='rg --hidden --files -F'
export FZF_CTRL_T_COMMAND='rg --hidden --files -F'
export FZF_DEFAULT_OPTS="--height 25% --border"


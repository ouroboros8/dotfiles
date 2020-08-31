# =================================
# == ZSH/ohmyzsh initianlisation ==
# =================================

# Toggle the comment below to profile zsh start speed
#zmodload zsh/zprof

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

antigen use oh-my-zsh
antigen theme avit

antigen apply


# =======================
# == Utility functions ==
# =======================

alert () {
    echo "\e[1;31m$@\e[0m"
}


# ===============
# == OSX hacks ==
# ===============

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

    # Add python user packages (installed with pip install --user <package>) to PATH
    latest_python3=$(ls -d ~/Library/Python/3.* | sort -t. -k2,2 -n | tail -n1)
    path=( "$latest_python3/bin" $path )
fi


# ========================
# == ZSH settings ==
# ========================

# Zsh completion help
bindkey '^Xh' _complete_help

# Incremental search
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^F' history-incremental-pattern-search-forward

# Biggest history
export HISTSIZE=9999999999999999 # LONG_MAX (64-bit)
export SAVEHIST=9999999999999999


# ======================
# == Dev environments ==
# ======================

# virtualenvwrapper

virtualenvwrapper_path="$(whence virtualenvwrapper.sh)"
if [[ -f "$virtualenvwrapper_path" ]]; then
    export VIRTUALENVWRAPPER_PYTHON="$(whence python3 || whence python)"
    export WORKON_HOME=~/.virtualenvs
    source "$virtualenvwrapper_path"
fi
# ... and pipenv completion
if whence pipenv >/dev/null ; then
    eval $(pipenv --completion)
fi

## poetry
[[ -d ~/.poetry/bin/ ]] && path=( ~/.poetry/bin/ $path )

## Go
if whence go >/dev/null; then
    GOPATH="$HOME/.local/go"
    mkdir -p $GOPATH
    export GOPATH
    path=( "$GOPATH/bin" $path )
fi

## Rust
if [ -d "$HOME/.cargo/" ]; then
    path=( "$HOME/.cargo/bin" $path )

    if whence rustup >/dev/null; then
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

## Jenv
if [ -d "$HOME/.jenv/" ]; then
    path=( "$HOME/.jenv/bin" $path )
    eval "$(jenv init -)"
fi

## Ruby
if [ -d ~/.rbenv/bin ]; then
    path=( "$HOME/.rbenv/bin" $path)
fi


#=================
#== Power Tools ==
#=================

# Inventory the toolbox
expected_tools=(
    # Essentials
    git
    docker
    shellcheck
    htop
    tree

    # Networking
    curl
    nc
    dig
    rsync

    # Power tools
    rg
    fzf
    fd
    zoxide
)

missing=()
for tool in $@; do
    if ! whence "$tool" >/dev/null; then
        missing+=("$tool")
    fi
done
if [[ ${#missing[@]} -ne 0 ]]; then
    alert Expected ${(j., .)missing} to be installed
fi

# fzf (https://github.com/junegunn/fzf)
if whence fzf >/dev/null; then
    export FZF_DEFAULT_OPTS="--height 25% --border"
    if whence rg >/dev/null; then
        export FZF_DEFAULT_COMMAND='rg --hidden --files -F'
        export FZF_CTRL_T_COMMAND='rg --hidden --files -F'
    fi
    if [[ -d /usr/share/fzf ]]; then
        source /usr/share/fzf/key-bindings.zsh
        source /usr/share/fzf/completion.zsh
    elif [[ -d /usr/local/Cellar/fzf ]]; then
        # This glob is hacky but we should only have one fzf version intalled
        source /usr/local/Cellar/fzf/*/shell/key-bindings.zsh
        source /usr/local/Cellar/fzf/*/shell/completion.zsh
    fi
fi

# zoxide
eval "$(zoxide init --cmd j zsh)"


#=================
#== Environment ==
#=================

## Editor
if whence nvim >/dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

## gpg-agent (with SSH support)
gpg-connect-agent /bye 2>&1 >/dev/null
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

## gopass completion
export fpath=( "$HOME/.local/go/share/zsh/site-functions" $fpath )


# ==============
# == Includes ==
# ==============

# work config
if [[ -f "$HOME/.work-dotfiles/zshrc" ]]; then
    source "$HOME/.work-dotfiles/zshrc"
fi

# aliases
source ~/.dotfiles/aliases.zsh


# ==================
# == Final checks ==
# ==================

# Scripts in ~/.local/bin take precedence:
path=( ~/.local/bin $path )

# dedupe path array (-U is for unique array)
typeset -aU path
export path

# Print packages to update
# requires passwordless sudo: <username> ALL=(ALL) NOPASSWD: /usr/bin/pacman
if grep 'Arch Linux' /etc/os-release >/dev/null 2>&1; then
    sudo pacman -Syup --print-format "%n"
fi

# Check that the dotfiles branch is correct for platform
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

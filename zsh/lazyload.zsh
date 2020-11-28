nvm () {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm "$@"
}

_initvirtualenvwrapper () {
    virtualenvwrapper_path="$(whence virtualenvwrapper.sh)"
    if [[ -f "$virtualenvwrapper_path" ]]; then
        export VIRTUALENVWRAPPER_PYTHON="$(whence python3 || whence python)"
        export WORKON_HOME=~/.virtualenvs
        source "$virtualenvwrapper_path"
    fi
}

virtualenvwrapper () {
    _initvirtualenvwrapper
    virtualenvwrapper "$@"
}

mkvirtualenv () {
    _initvirtualenvwrapper
    mkvirtualenv "$@"
}

jenv () {
    if [ -d "$HOME/.jenv/" ]; then
        path=( "$HOME/.jenv/bin" $path )
        eval "$(jenv init -)"
    fi
}

rbenv () {
    if [ -d ~/.rbenv/bin ]; then
        path=( "$HOME/.rbenv/bin" $path)
        eval "$(rbenv init -)"
    fi
}

j () {
    eval "$(zoxide init --cmd j zsh)"
    j "$@"
}

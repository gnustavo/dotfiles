# http://www.dagolden.com/index.php/2390/setting-up-a-perl-development-environment-with-plenv/
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"

# https://github.com/yyuu/pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export EDITOR=emacsclient

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

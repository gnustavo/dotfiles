# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
#export PERLBREW_ROOT=/opt/perl/perl5/perlbrew
#export PERLBREW_HOME=/opt/perl/.perlbrew
#export PYTHONPATH=/home/gustavo/lib/python

export EDITOR=emacsclient

# http://www.dagolden.com/index.php/2390/setting-up-a-perl-development-environment-with-plenv/
export PATH="$HOME/.plenv/bin:$PATH"
eval "$(plenv init -)"

# https://github.com/yyuu/pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

PATH=$PATH:~/libexec/git-extensions

export SHELL=/bin/bash

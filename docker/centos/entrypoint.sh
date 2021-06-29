#!/bin/bash

export LC_ALL=en_US.UTF-8

export PYENV_ROOT="$HOME/.pyenv"   
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"        
pyenv global 3.8.3
source scl_source enable rh-ruby23

exec "$@"

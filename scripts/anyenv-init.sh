#!/bin/bash

ANYENV_DEFINITION_ROOT=$HOME/.config/anyenv/anyenv-install

if [ ! -d $ANYENV_DEFINITION_ROOT ]; then
    anyenv install --force-init
fi

#!/bin/bash

export workspace=$1

## setup and load nvm
export NVM_DIR="$(pwd)/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>/dev/null # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" >/dev/null 2>/dev/null # This loads nvm bash_completion

if ! [ -f $workspace/.theia ]; then
    mkdir  $workspace/.theia
fi

if ! [ -f $workspace/.theia/launch.json ]; then
    cp $(pwd)/launch.json $workspace/.theia/
fi

## set the VS code plugins dir
export THEIA_DEFAULT_PLUGINS=local-dir://$(pwd)/vscode-plugins

## run theia-ide
yarn theia start $workspace --startup-timeout -1 --hostname 0.0.0.0 --port 3000

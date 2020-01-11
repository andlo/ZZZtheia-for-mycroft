#!/bin/bash

## setup and load nvm
#export NVM_DIR="$(pwd)/nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>/dev/null # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" >/dev/null 2>/dev/null # This loads nvm bash_completion

if ![ -f $1/.theia/launch.json ]; then
    cp launch.json $(pwd)/.theia/
fi

## set the VS code plugins dir
export THEIA_DEFAULT_PLUGINS=local-dir://$(pwd)/vscode-plugins

## run theia-ide
yarn theia start $1 --startup-timeout -1 --hostname 0.0.0.0 --port 3000 


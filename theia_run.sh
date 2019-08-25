#!/bin/bash
cd $1

## If on Mark_1 enter venv
if [ -f /opt/venvs/mycroft-core/bin/activate ]; then
    source /opt/venvs/mycroft-core/bin/activate
fi

## setup and load nvm

export NVM_DIR="$(pwd)/nvm"

# install nvm if not alreddy present
if [ ! -d $NVM_DIR ]; then
    curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash >/dev/null 2>/dev/null
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>/dev/null # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" >/dev/null 2>/dev/null # This loads nvm bash_completion

## Copy launch.json to workspce if not exist
if [ ! -f /opt/mycroft/skills/.theia/launch.json ]; then
    if [ ! -d /opt/mycroft/skills/.theia ]; then
        mkdir /opt/mycroft/skills/.theia
    fi
    cp launch.json /opt/mycroft/skills/.theia/launch.json
fi

## set the VS code plugins dir
export THEIA_DEFAULT_PLUGINS=local-dir://$1/vscode-plugins

## run theia-ide
yarn theia start /opt/mycroft/skills  --startup-timeout -1 --hostname 0.0.0.0 --port 3000 >/dev/null 2>/dev/null

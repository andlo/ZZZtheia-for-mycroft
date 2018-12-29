#!/bin/bash
cd $1

## If on Mark_1 enter venv
if [ -f /opt/venvs/mycroft-core/bin/activate ]; then
    source /opt/venvs/mycroft-core/bin/activate
fi

## If on picroft enter venv
#if [ -f /home/pi/mycroft-core/venv-activate.sh ]; then
#    /home/pi/mycroft-core/venv-activate.sh
#fi

## setup and load nvm
export NVM_DIR="$(pwd)/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>/dev/null # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" >/dev/null 2>/dev/null # This loads nvm bash_completion

## make sure git is working
export LOCAL_GIT_DIRECTORY="$(pwd)/node_modules/dugite/git"
export GIT_EXEC_PATH="$(pwd)/node_modules/dugite/git/libexec/git-core"
export PATH=$(pwd)/node_modules/dugite/git/bin:$(pwd)/node_modules/dugite/git/libexec/git-core:$PATH

#set the VS code plugins dit
export THEIA_DEFAULT_PLUGINS=local-dir://$HOME/theia-plugins
## run theia-ide
yarn theia start /opt/mycroft/skills  --startup-timeout -1 --hostname 0.0.0.0 --port 3000

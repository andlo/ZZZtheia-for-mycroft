#!/bin/bash
cd $(dirname "$0")
#cd $(pwd)

## enter .venv
## If picroft
if [ -f /home/pi/mycroft-core/.venv/bin/activate ]; then
    source /home/pi/mycroft-core/.venv/bin/activate
    export PATH="$HOME/bin:$HOME/mycroft-core/bin:$PATH"
fi
## if mark_1
if [ -f /opt/venvs/mycroft-core/bin/activate ]; then
    source /opt/venvs/mycroft-core/bin/activate
fi

curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install 8
npm install -g yarn

yarn
yarn theia build

mycroft-pip install python-language-server

cp -u $(pwd)/editorconfig $HOME/.editorconfig


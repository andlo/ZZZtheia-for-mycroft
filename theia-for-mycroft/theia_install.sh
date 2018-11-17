#!/bin/bash
cd $(dirname "$0")
#cd $(pwd)

curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install 8
npm install -g yarn

yarn
yarn theia build

mycroft-pip install python-language-server

cp -u $(pwd)/.editorconfig /opt/mycroft/skills

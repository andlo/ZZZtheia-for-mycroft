#!/bin/bash
export NVM_DIR=$(pwd)/nvm
mkdir $NVM_DIR

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  >/dev/null 2>/dev/null # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  >/dev/null 2>/dev/null # This loads nvm bash_completion

export NODE_OPTIONS=--max_old_space_size=4096

echo "Intstalling node..."
nvm install 10
echo "Installling yarn..."
npm install -g yarn

echo "Building theia..."

yarn
yarn theia build
yarn autoclean --init
echo *.ts >> .yarnclean
echo *.ts.map >> .yarnclean
echo *.spec.* >> .yarnclean
yarn autoclean --force
rm -rf ./node_modules/electron
rm -rd nvm/.cache/
yarn cache clean

echo "Building theia...OK"

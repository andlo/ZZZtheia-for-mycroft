#!/bin/bash
export NVM_DIR=$(pwd)/nvm
mkdir $NVM_DIR

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  >/dev/null 2>/dev/null # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  >/dev/null 2>/dev/null # This loads nvm bash_completion

export NODE_OPTIONS=--max_old_space_size=1024

echo "Intstalling node..."
nvm install 10
echo "Installling yarn..."
npm install -g yarn

echo "Building theia..."

yarn
#yarn --pure-lockfile
yarn theia build
#yarn --production
yarn autoclean --init
echo *.ts >> .yarnclean
echo *.ts.map >> .yarnclean
echo *.spec.* >> .yarnclean
yarn autoclean --force
rm -rf ./node_modules/electron
rm -rd nvm/.cache/
yarn cache clean

# instll vscode python plugin
mkdir vscode-plugins
cd vscode-plugins
wget https://github.com/$(wget https://github.com/Microsoft/vscode-python/releases/latest -O- | egrep '/.*/.*/.*vsix' -o)
cd ..

cd ..
echo "Building theia...OK"

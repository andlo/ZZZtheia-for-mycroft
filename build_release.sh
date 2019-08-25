#!/bin/bash
RELDIR="$(pwd)/release"
mkdir release

export NVM_DIR="$RELDIR/nvm"
mkdir $NVM_DIR

cp theia_run.sh $RELDIR
cp package.json $RELDIR

cd $RELDIR

echo "Installing nvm..."
curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash >/dev/null 2>/dev/null

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  >/dev/null 2>/dev/null # This loads nvm

export NODE_OPTIONS=--max_old_space_size=1024

echo "Installing node..."
nvm install 10 >/dev/null 2>/dev/null 

echo "Installing yarn..."
npm install -g yarn >/dev/null 2>/dev/null 

echo "Building theia..."
yarn
#yarn --pure-lockfile
yarn theia build
echo "Cleaning up..."
#yarn --production
yarn autoclean --init
echo *.ts >> .yarnclean
echo *.ts.map >> .yarnclean
echo *.spec.* >> .yarnclean
yarn autoclean --force
rm -rf ./node_modules/electron*
yarn cache clean

echo "Downloading Microsoft VS-code plugin..."
mkdir vscode-plugins
cd vscode-plugins
wget https://github.com/$(wget https://github.com/Microsoft/vscode-python/releases/latest -O- | egrep '/.*/.*/.*vsix' -o) >/dev/null 2>/dev/null
cd ..
cd ..
echo "Packing theia...."
rm -rf $NVM_DIR
cd $RELDIR
tar -czvf theiaide-picroft.tgz *
mv tar -czvf theia-mycroft-$(uname -m)-$(date +%Y%m%d).tgz ..
cd ..
rm -rf $RELDIR
echo "Building theia...OK"

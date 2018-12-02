#!/bin/bash
RELDIR="$(pwd)/release"
mkdir release

export NVM_DIR="$RELDIR/nvm"
mkdir $NVM_DIR

cp theia_run.sh $RELDIR
cp package.json $RELDIR

cd release

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  >/dev/null 2>/dev/null # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  >/dev/null 2>/dev/null # This loads nvm bash_completion


echo "Intstalling node..."
nvm install 8
echo "Installling yarn..."
npm install -g yarn

echo "Building theia..."
yarn
yarn theia build
cd ..
echo "Building theia...OK"


echo "Building git..."
echo "Installing depencies..."
apt-get -y install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev >/dev/null 2>/dev/null
echo "Cloning git..."
git clone git://git.kernel.org/pub/scm/git/git.git
cd git
echo "Compiling git..."
make configure 

CC='gcc' \
  CFLAGS='-Wall -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -U_FORTIFY_SOURCE' \
  LDFLAGS='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
  ./configure \
  --prefix=""

echo "Installing git...into node_modules/dugite/git"

DESTDIR="$RELDIR/node_modules/dugite/git" \
    NO_PERL=1 \
    NO_TCLTK=1 \
    NO_GETTEXT=1 \
    NO_INSTALL_HARDLINKS=1 \
    NO_R_TO_GCC_LINKER=1 \
    make strip install


echo "-- Removing server-side programs"
rm "$RELDIRapt-get -y install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev >/dev/null 2>/dev/null
echo "Cloning git..."
git clone git://git.kernel.org/pub/scm/git/git.git >/dev/null 2>/dev/null
cd git
echo "Compiling git..."
make configure 

CC='gcc' \
  CFLAGS='-Wall -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -U_FORTIFY_SOURCE' \
  LDFLAGS='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
  ./configure \
  --prefix=""

echo "Installing git...into node_modules/dugite/git"

DESTDIR="$RELDIR/node_modules/dugite/git" \
    NO_PERL=1 \
    NO_TCLTK=1 \
    NO_GETTEXT=1 \
    NO_INSTALL_HARDLINKS=1 \
    NO_R_TO_GCC_LINKER=1 \
    make strip install 


echo "-- Removing server-side programs"
rm "$RELDIR/node_modules/dugite/git/bin/git-cvsserver"
rm "$RELDIR/node_modules/dugite/git/bin/git-receive-pack"
rm "$RELDIR/node_modules/dugite/git/bin/git-upload-archive"
rm "$RELDIR/node_modules/dugite/git/bin/git-upload-pack"
rm "$RELDIR/node_modules/dugite/git/bin/git-shell"

echo "-- Removing unsupported features"
rm "$RELDIR/node_modules/dugite/libexec/git-core/git-svn"
rm "$RELDIR/node_modules/dugite/libexec/git-core/git-remote-testsvn"
rm "$RELDIR/node_modules/dugite/libexec/git-core/git-p4"

cd ..
rm -r git/ >/dev/null 2>/dev/null/node_modules/dugite/git/bin/git-cvsserver"
rm "$RELDIR/node_modules/dugite/git/bin/git-receive-pack"
rm "$RELDIR/node_modules/dugite/git/bin/git-upload-archive"
rm "$RELDIR/node_modules/dugite/git/bin/git-upload-pack"
rm "$RELDIR/node_modules/dugite/git/bin/git-shell"

echo "-- Removing unsupported features"
rm "$RELDIR/node_modules/dugite/libexec/git-core/git-svn"
rm "$RELDIR/node_modules/dugite/libexec/git-core/git-remote-testsvn"
rm "$RELDIR/node_modules/dugite/libexec/git-core/git-p4"

cd ..
rm -r git


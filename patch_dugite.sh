#!/bin/bash
RELDIR="$(pwd)/release"

# Due to module dugitehassnt a git precompiled for ARM32 we need to compile this
# MOst of the next stuff is from dugites script for building for ARM64
# https://github.com/desktop/dugite-native/blob/master/script/build-arm64-git.sh

echo "Building git..."
echo "Installing depencies..."

sudo apt-get -y install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev >/dev/null 2>/dev/null
echo "Cloning git..."
git clone git://git.kernel.org/pub/scm/git/git.git >/dev/null 2>/dev/null
cd git
echo "Compiling git..."
make configure

CC='gcc' \
  CFLAGS='-Wall -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -U_FORTIFY_SOURCE' \
  LDFLAGS='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
  ./configure \
  --prefix=/

echo "Installing git...into node_modules/dugite/git"
rm -r -f $RELDIR/node_modules/dugite/git
mkdir $RELDIR/node_modules/dugite/git

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
# rm -r git >/dev/null 2>/dev/null


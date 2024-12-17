#!/bin/zsh

set -e
set -o pipefail

cd $(dirname "$0")

rm -rf Build/
mkdir Build/

pushd Build/
PREFIX=$(pwd)
echo "[*] export PREFIX=$PREFIX"
popd

pushd Core
git clean -fdx -f
git reset --hard

echo "[*] Building Git Core"
make configure
./configure --prefix=$PREFIX
make -j10
make install


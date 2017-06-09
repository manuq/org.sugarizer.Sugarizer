#! /usr/bin/env bash

# Note there is a .yarnrc inside electron/ that will instruct Yarn to
# use an "Offline mirror" folder.  This folder will be recreated in
# the Flatpak build directory.
mkdir -p electron/npm-offline-cache
pushd electron
rm -rf node_modules/
node yarn-0.24.6.js cache clean
node yarn-0.24.6.js install --non-interactive
popd

./add-npm-deps.py electron/yarn.lock \
                  org.sugarizer.Sugarizer.json.in \
                  sugarizer \
                  electron/npm-offline-cache/ \
                  --dest electron/npm-offline-cache/ \
                  > org.sugarizer.Sugarizer.json


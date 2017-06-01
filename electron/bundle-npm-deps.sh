#! /bin/bash

download_npm=false
if hash npm 2>/dev/null; then
    npm_version=$(npm --version)
    if [[ ! "$npm_version" == 5* ]]; then
        download_npm=true
    fi
else
    download_npm=true
fi

if ! $download_npm; then
    echo "Using system installed npm"
    npm5=npm
else
    echo "Downloading npm..."
    wget https://registry.npmjs.org/npm/-/npm-5.0.0.tgz
    if ! sha256sum --quiet -c npm5-sha256sum < npm-5.0.0.tgz; then
        echo "Error downloading npm"
        exit 1
    fi
    tar -zxf npm-5.0.0.tgz
    mv package npm5
    npm5=npm5/bin/npm-cli.js
fi

echo "Bundling npm cache..."
rm -rf node_modules cache package-lock.json npm-cache.tgz
mkdir cache
ORIG_CACHE=`$npm5 config get cache`
$npm5 config set cache ./cache
$npm5 install
pushd cache
tar -zcf ../npm-cache.tgz *
popd
$npm5 config set cache ${ORIG_CACHE}

echo "Bundling node_modules/..."
tar -zcf node-modules.tgz node_modules/

wget https://github.com/electron/electron/releases/download/v1.6.10/electron-v1.6.10-linux-x64.zip
wget https://github.com/electron/electron/releases/download/v1.6.10/SHASUMS256.txt
mv SHASUMS256.txt SHASUMS256.txt-1.6.10

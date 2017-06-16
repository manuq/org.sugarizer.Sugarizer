#!/usr/bin/env python3
import os
import re
import sys
import json
import hashlib
import argparse
from collections import OrderedDict

# Used to read the tarballs by chunks to obtain the checksums.
BUF_SIZE = 2**16

parser = argparse.ArgumentParser(description='Add npm dependencies to flatpak manifest.')
parser.add_argument('yarn_lock', type=argparse.FileType('r'), help='Path to the yarn.lock file.')
parser.add_argument('flatpak_manifest', type=argparse.FileType('r'), help='Path to the flatpak manifest. '
                    'Must be a template with a {{ NPM_DEPENDENCIES }} that will be replaced.')
parser.add_argument('module', help='The module name to add the tarballs as sources.')
parser.add_argument('yarn_offline_cache_dir', help='Path to the yarn offline mirror directory. '
                    'The script assumes that all the tarballs have been already downloaded to '
                    'validate them with the checksums in yarn.lock .')
args = parser.parse_args()

if not os.path.isdir(args.yarn_offline_cache_dir):
    raise parser.error("'yarn_offline_cache_dir' Must be a directory.")

def get_checksums(filename):
    sha1 = hashlib.sha1()
    sha256 = hashlib.sha256()
    with open(filename, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            sha1.update(data)
            sha256.update(data)
    return sha1.hexdigest(), sha256.hexdigest()

sources_list = []
for line in args.yarn_lock:
    result = re.match(r'^resolved "(.*)#(.*)"', line.strip())
    if not result:
        continue
    url, shasum = result.groups()
    filename = os.path.join(args.yarn_offline_cache_dir, os.path.basename(url))
    if re.match(r'^https://(.*)@types/', url):
        filename = os.path.join(os.path.dirname(filename), '@types-' + os.path.basename(filename))
    if not os.path.exists(filename):
        print("Not adding {}, file not found.".format(filename), file=sys.stderr)
        continue
    sha1, sha256 = get_checksums(filename)
    assert shasum == sha1
    source = OrderedDict()
    source['type'] = "file"
    source['url'] = url
    source['sha256'] = sha256
    if '@types' in url:
        source['dest-filename'] = os.path.basename(filename)
    sources_list.append(source)

sources_str = '\n'.join(json.dumps(sources_list, indent=4).splitlines()[1:-1])
print(args.flatpak_manifest.read().replace("{{ NAME }}", args.module, 1).replace("{{ NPM_DEPENDENCIES }}", sources_str, 1))

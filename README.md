# monero-torrent

create a torrent of all monero release binaries with a deterministic file info hash. seeding this is left up to the user currently

- a multi file torrent with getmonero added as a [webseed](https://fosstorrents.com/blog/torrents-with-web-seeds/)
- [mktorrent](https://github.com/pobrn/mktorrent) creates the torrent file.
- the torrent files [info-hash](https://stackoverflow.com/a/28601408) is deterministic.

the shell script outputs this:
```
├── create_monero_torrent.sh
├── downloads
│   └── monero-v0.18.4.2
│       ├── binaryfate.asc
│       ├── cli
│       │   ├── monero-android-armv7-v0.18.4.2.tar.bz2
│       │   ├── monero-android-armv8-v0.18.4.2.tar.bz2
│       │   ├── monero-freebsd-x64-v0.18.4.2.tar.bz2
│       │   ├── monero-linux-armv7-v0.18.4.2.tar.bz2
│       │   ├── monero-linux-armv8-v0.18.4.2.tar.bz2
│       │   ├── monero-linux-riscv64-v0.18.4.2.tar.bz2
│       │   ├── monero-linux-x64-v0.18.4.2.tar.bz2
│       │   ├── monero-linux-x86-v0.18.4.2.tar.bz2
│       │   ├── monero-mac-armv8-v0.18.4.2.tar.bz2
│       │   ├── monero-mac-x64-v0.18.4.2.tar.bz2
│       │   ├── monero-source-v0.18.4.2.tar.bz2
│       │   ├── monero-win-x64-v0.18.4.2.zip
│       │   └── monero-win-x86-v0.18.4.2.zip
│       ├── gui
│       │   ├── monero-gui-install-win-x64-v0.18.4.2.exe
│       │   ├── monero-gui-linux-x64-v0.18.4.2.tar.bz2
│       │   ├── monero-gui-mac-armv8-v0.18.4.2.dmg
│       │   ├── monero-gui-mac-x64-v0.18.4.2.dmg
│       │   ├── monero-gui-source-v0.18.4.2.tar.bz2
│       │   └── monero-gui-win-x64-v0.18.4.2.zip
│       └── hashes.txt
└── watch
    └── monero-v0.18.4.2.torrent
```
# usage

Grab the torrent from https://github.com/plowsof/monero-torrent/releases

To build the torrent file:
- Clone this repo, build and copy the mktorrent binary to the `monero-torrent` dir and run `create_monero_torrent.sh`:
```
git clone --recurse-submodules https://github.com/plowsof/monero-torrent && cd monero-torrent && cd submodules/mktorrent && make && mv mktorrent ../../ && cd ../.. && chmod +x create_monero_torrent.sh && ./create_monero_torrent.sh
```

- By default the script downloads binaries from getmoneros CDN
- you can specify the local path of `binaryfate.asc` , `hashes.txt` and the CDN base dir which contains the latest monero binaries. _Note: they do not have to be nested in any particular folder, the script will find them recursively and copy them into the torrents file folder_

```
CDN_URL="$HOME/monero-v0.18.4.3" \
BF_KEY_URL="$HOME/binaryfate.asc" \
HASHES_URL="$HOME/hashes.txt" \
./create_monero_torrent.sh
```

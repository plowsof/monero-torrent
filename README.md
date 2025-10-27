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
│       └── hashes-v0.18.4.2.txt
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
- to obtain files locally, pass `CDN_URL` which is a path containing all files required including `binaryfate.asc` and `hashes.txt`
- `BF_KEY_URL` is the filename of the key inside the `CDN_URL` folder.
- `HASHES_URL` is the filename of the hashes file in `CDN_URL` folder. (to support a versioned hashes-v*.txt)

_Note: they do not have to be nested in any particular folder, the script will find them recursively and copy them into the torrents file folder_

```
CDN_URL="$HOME/monero-v0.18.4.3" \
BF_KEY_URL="binaryfate.asc" \
HASHES_URL="hashes.txt" \
./create_monero_torrent.sh
```

# docker

if you see `ContainerConfig` error you need to upgrade docker-compose. In debian:

``
sudo apt-get remove docker-compose
sudo apt-get install docker-compose-plugin
``

env variables are defined in docker-compose.yml

Default where files are downloaded:

```
docker compose --profile remote up
```

```
docker compose --profile local up
```

# seeding

this is left up to the user, but after running the scripts you can add the torrent / files to your favourite client. _Note: ensure the correct port(s) are open for your client_

example with `transmission-daemon`:

```
transmission-daemon --config-dir ./config --download-dir ./downloads --watch-dir ./watch --foreground
```

for some automation linux/debian users can install inotifywait which can watch a directory for new files.
when i push a torrent file to the `watch` folder - a script to remove the old torrent files is run.
the webseed will be used to bootstrap the first seed node, simple.

```
apt install inotify-tools
```

running `./inotify.sh` in a screen session will delete old torrent files when a new Monero torrent is placed in the `./watch` folder.

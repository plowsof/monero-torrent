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

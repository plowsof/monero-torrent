#!/bin/bash

WATCH_DIR="./watch"
DOWNLOAD_DIR="./downloads"

# https://superuser.com/a/959040
inotifywait -m -r -e create --format '%w%f' "$WATCH_DIR" | while read -r NEWFILE; do
  BASE_NAME=$(basename "$NEWFILE")
  echo "new file: $BASE_NAME"
  IS_MONERO=0
  case $BASE_NAME in
    monero-v*.torrent|monero-gui-v*.torrent)
    IS_MONERO=1
    BASE_NAME="${BASE_NAME%.torrent}"
    ;;
  *)
    ;;
  esac
  if [ "$IS_MONERO" == 1 ]; then
    # https://stackoverflow.com/a/68140834
    PREFIX="monero-gui-v"
    [[ $BASE_NAME != monero-gui-v* ]] && PREFIX="monero-v"
    NEW_VER="${BASE_NAME#$PREFIX}"

    echo "New Monero version: $NEW_VER" # "0.18.4.3"
    for OLD_DIR in "$DOWNLOAD_DIR/$PREFIX"*; do
      OLD_VER="${OLD_DIR##*/$PREFIX}"
      if [ "$OLD_VER" != "$NEW_VER" ]; then
        echo "Deleting: $OLD_DIR"
        rm -rf "$OLD_DIR"
      fi
    done

    for OLD_TORRENT in "$WATCH_DIR/$PREFIX"*.torrent; do
      OLD_VER="${OLD_TORRENT##*/$PREFIX}"
      OLD_VER="${OLD_VER%.torrent}"
      if [ "$OLD_VER" != "$NEW_VER" ]; then
        echo "Deleting: $OLD_TORRENT"
        rm -f "$OLD_TORRENT"
      fi
    done

  fi
done

#!/bin/bash

#todo the this:-or_this trick
OUTPUT_DIR="downloads"
TORRENT_DIR="watch"

# afaict the only important thing for hash determinism is piece size
PIECE_SIZE=512

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TORRENT_DIR"

# reinvent the wheel and download/verify binaries
curl -sL https://www.getmonero.org/downloads/hashes.txt -o "$OUTPUT_DIR/hashes.txt"
curl -sL https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc -o "$OUTPUT_DIR/binaryfate.asc"
gpg --import "$OUTPUT_DIR/binaryfate.asc"
gpg --verify "$OUTPUT_DIR/hashes.txt"

version=$(awk '/monero-source-v/ {print $2}' "$OUTPUT_DIR/hashes.txt" | awk -F".tar.bz2" '{print $1}' | awk -F"-" '{print $3}')
torrent="monero-$version"
torrent_comment="Multi file torrent for the Monero project $version"

mkdir -p "$OUTPUT_DIR/$torrent"

mv "$OUTPUT_DIR/hashes.txt" "$OUTPUT_DIR/$torrent/"
mv "$OUTPUT_DIR/binaryfate.asc" "$OUTPUT_DIR/$torrent/"

for file in $(awk '/monero-/ {print $2}' "$OUTPUT_DIR/$torrent/hashes.txt"); do
  dir=cli
  if [[ $file =~ gui ]]; then
      dir=gui
  fi
  # dont re-download if exists
  [ -f "$OUTPUT_DIR/$torrent/$dir/$file" ] && continue
  echo "Downloading $file..."
  url=https://dlsrc.getmonero.org/${dir}/${file}
  # make sure subdir exists
  mkdir -p "$OUTPUT_DIR/$torrent/$dir"
  # webseed compatible https://www.bittorrent.org/beps/bep_0019.html
  curl -sLO --output-dir "$OUTPUT_DIR/$torrent/$dir" "$url"
done

cd "$OUTPUT_DIR/$torrent"

grep 'monero-' hashes.txt | while read -r hash file; do
  path="cli/$file"
  if [[ $file =~ gui ]]; then
    path="gui/$file"
  fi

  echo "$hash  $path" | sha256sum -c - || {
    echo "Hash check failed for $path"
    exit 1
  }
done

cd ../..

#transmission-create -s "$PIECE_SIZE" -o "$TORRENT_DIR/$torrent.torrent" --anonymize "$OUTPUT_DIR/$torrent"
# prints the magnet link
#transmission-show -m "$TORRENT_DIR/$torrent.torrent"

#transmission-show "$TORRENT_DIR/$torrent.torrent"

py3createtorrent -p 512 -o watch/ -c "$torrent_comment" --webseed "https://dlsrc.getmonero.org/" --webseed "http://node.monerodevs.org/" -v $OUTPUT_DIR/$torrent

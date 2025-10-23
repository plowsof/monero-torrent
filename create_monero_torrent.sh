#!/bin/bash
set -e
set -o pipefail

#remote url or local full path
#local_cdn_dir
#├── cli
#    ├── monero_cli_files
#└── gui
#    ├── monero-gui-files
CDN_URL="${CDN_URL:-https://dlsrc.getmonero.org}"
OUTPUT_DIR="${OUTPUT_DIR:-downloads}"
TORRENT_DIR="${TORRENT_DIR:-watch}"
HASHES_URL="${HASHES_URL:-https://www.getmonero.org/downloads/hashes.txt}"
BF_KEY_URL="${BF_KEY_URL:-https://raw.githubusercontent.com/monero-project/monero/master/utils/gpg_keys/binaryfate.asc}"

# afaict the only important thing for hash determinism is piece size
PIECE_SIZE=21

mkdir -p "$OUTPUT_DIR"
mkdir -p "$TORRENT_DIR"

is_url() {
    case "$1" in
        http://*|https://*) return 0 ;;
        *) return 1 ;;
    esac
}

# reinvent the wheel and download/verify binaries
if is_url "$HASHES_URL"; then
  curl -sL $HASHES_URL -o "$OUTPUT_DIR/hashes.txt"
else
  cp $HASHES_URL "$OUTPUT_DIR/hashes.txt"
fi

if is_url "$BF_KEY_URL"; then
  curl -sL $BF_KEY_URL -o "$OUTPUT_DIR/binaryfate.asc"
else
  cp $BF_KEY_URL "$OUTPUT_DIR/binaryfate.asc"
fi

gpg --import "$OUTPUT_DIR/binaryfate.asc"
gpg --verify "$OUTPUT_DIR/hashes.txt"

version=$(awk '/monero-source-v/ {print $2}' "$OUTPUT_DIR/hashes.txt" | awk -F".tar.bz2" '{print $1}' | awk -F"-" '{print $3}')
torrent="monero-$version"
torrent_comment="Multi file torrent for the Monero project $version"

mkdir -p "$OUTPUT_DIR/$torrent"

mv "$OUTPUT_DIR/hashes.txt" "$OUTPUT_DIR/$torrent/hashes-$version.txt"
mv "$OUTPUT_DIR/binaryfate.asc" "$OUTPUT_DIR/$torrent/"

for file in $(awk '/monero-/ {print $2}' "$OUTPUT_DIR/$torrent/hashes-$version.txt"); do
  dir=cli
  if [[ $file =~ gui ]]; then
      dir=gui
  fi
  # dont re-download if exists
  [ -f "$OUTPUT_DIR/$torrent/$dir/$file" ] && continue
  url=$CDN_URL/${dir}/${file}
  # make sure subdir exists
  mkdir -p "$OUTPUT_DIR/$torrent/$dir"
  # webseed compatible https://www.bittorrent.org/beps/bep_0019.html
  if is_url "$CDN_URL"; then
    curl -sLO --output-dir "$OUTPUT_DIR/$torrent/$dir" "$url"
  else
    cp $url "$OUTPUT_DIR/$torrent/$dir"
  fi
done

cd "$OUTPUT_DIR/$torrent"

grep 'monero-' hashes-$version.txt | while read -r hash file; do
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

./mktorrent -l $PIECE_SIZE -o "$TORRENT_DIR/$torrent.torrent" -n $torrent -c "$torrent_comment" -w "https://dlsrc.getmonero.org/" -v $OUTPUT_DIR/$torrent

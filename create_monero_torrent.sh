#!/bin/bash
set -e
set -o pipefail

#CDN_URL remote must have this structure:
#├── cli
#    ├── monero_cli_files
#└── gui
#    ├── monero-gui-files
#CDN_URL local no nesting required, just place all files in the folder.
DEFAULT_CDN_URL="https://downloads.getmonero.org"
CDN_URL="${CDN_URL:-$DEFAULT_CDN_URL}"
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
  # recursively find a file https://stackoverflow.com/a/656744
  src_file=$(find "$CDN_URL" -type f -name "$HASHES_URL" -print -quit)
  if [ "$src_file" ]; then
    cp "$src_file" "$OUTPUT_DIR/hashes.txt"
  else
    echo "$file not found in $CDN_URL"
    exit 1
  fi
fi

if is_url "$BF_KEY_URL"; then
  curl -sL $BF_KEY_URL -o "$OUTPUT_DIR/binaryfate.asc"
else
  # recursively find a file https://stackoverflow.com/a/656744
  src_file=$(find "$CDN_URL" -type f -name "$BF_KEY_URL" -print -quit)
  if [ "$src_file" ]; then
    cp "$src_file" "$OUTPUT_DIR/binaryfate.asc"
  else
    echo "$file not found in $CDN_URL"
    exit 1
  fi
fi

gpg --import "$OUTPUT_DIR/binaryfate.asc"
gpg --verify "$OUTPUT_DIR/hashes.txt"

cli_version=$(awk '/monero-source-v/ {print $2}' "$OUTPUT_DIR/hashes.txt" | awk -F".tar.bz2" '{print $1}' | awk -F"-" '{print $3}')
gui_version=$(awk '/monero-gui-source-v/ {print $2}' "$OUTPUT_DIR/hashes.txt" | awk -F".tar.bz2" '{print $1}' | awk -F"-" '{print $4}')
cli_torrent="monero-$cli_version"
gui_torrent="monero-gui-$gui_version"
gui_torrent_comment="Multi file torrent for the Monero project GUI $gui_version"
cli_torrent_comment="Multi file torrent for the Monero project $version"

mkdir -p "$OUTPUT_DIR/$cli_torrent"
mkdir -p "$OUTPUT_DIR/$gui_torrent"

for x in cli gui; do
    ver="$cli_version"
    folder="$cli_torrent"
    if [ "$x" = "gui" ]; then
        ver="$gui_version"
        folder="$gui_torrent"
    fi

    hash_file="hashes-$ver.txt"
    dest="$OUTPUT_DIR/$folder/$hash_file"

    if is_url "$CDN_URL"; then
        url="$CDN_URL/$hash_file"
        curl -sL "$url" -o "$dest"
    else
        # requires versioned hashes file in CDN path. 2 if gui/cli are on different versions
        src_file=$(find "$CDN_URL" -type f -name "$hash_file" -print -quit)
        if [ "$src_file" ]; then
            cp "$src_file" "$dest"
        else
            echo "Error: $hash_file not found in $CDN_URL"
            exit 1
        fi
    fi
done

for file in $(awk '/monero-/ {print $2}' "$OUTPUT_DIR/hashes.txt"); do
  dir=cli
  torrent=$cli_torrent
  echo $file
  if [[ $file =~ gui ]]; then
      dir=gui
      torrent=$gui_torrent
  fi
  # dont re-download if exists
  [ -f "$OUTPUT_DIR/$torrent/$dir/$file" ] && continue
  url=$CDN_URL/${dir}/${file}
  # make sure subdir exists
  mkdir -p "$OUTPUT_DIR/$torrent/$dir"
  # webseed compatible https://www.bittorrent.org/beps/bep_0019.html
  if is_url "$CDN_URL"; then
    echo $url
    curl -sLO --output-dir "$OUTPUT_DIR/$torrent/$dir" "$url"
  else
    # recursively find a file https://stackoverflow.com/a/656744
    src_file=$(find "$CDN_URL" -type f -name "$file" -print -quit)
    if [ "$src_file" ]; then
      cp "$src_file" "$OUTPUT_DIR/$torrent/$dir"
    else
      echo "$file not found in $CDN_URL"
      exit 1
    fi
  fi
done

cd "$OUTPUT_DIR"

grep 'monero-' hashes.txt | while read -r hash file; do
  path="$cli_torrent/cli/$file"
  if [[ $file =~ gui ]]; then
    path="$gui_torrent/gui/$file"
  fi

  echo "$hash  $path" | sha256sum -c - || {
    echo "Hash check failed for $path"
    exit 1
  }
done

cd ../

./mktorrent -l $PIECE_SIZE -o "$TORRENT_DIR/$cli_torrent.torrent" -n $cli_torrent -c "$cli_torrent_comment" -w "$DEFAULT_CDN_URL" -v $OUTPUT_DIR/$cli_torrent
./mktorrent -l $PIECE_SIZE -o "$TORRENT_DIR/$gui_torrent.torrent" -n $torrent -c "$gui_torrent_comment" -w "$DEFAULT_CDN_URL" -v $OUTPUT_DIR/$gui_torrent

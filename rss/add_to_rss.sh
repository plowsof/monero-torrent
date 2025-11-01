#!/usr/bin/env bash
set -euo pipefail

RSS_FILE="./rss/torrent-rss.xml"
TMP_FILE="./rss/torrent-rss.new.xml"

MAGNET_LINK="${MAGNET_LINK_LOCAL:-magnet:?xt=test123&123}"
# escape &
MAGNET_LINK="${MAGNET_LINK//&/&amp;}"
VERSION="${VERSION:-v0.18.0.0}"
TITLE="Monero $VERSION"
PUBDATE="$(date -R)"
INFOHASH="${INFOHASH:-123abc123abc}"

NEW_ITEM=$(cat <<EOF
  <item>
    <title>$TITLE</title>
    <link>$MAGNET_LINK</link>
    <guid isPermaLink="false">$INFOHASH</guid>
    <pubDate>$PUBDATE</pubDate>
    <description>Multi file torrent for Monero GUI/CLI $VERSION</description>
  </item>
EOF
)

# insert at top after channel
awk -v item="$NEW_ITEM" '
  /<channel>/ && !found {
    print
    print item
    found=1
    next
  }
  {print}
' "$RSS_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$RSS_FILE"

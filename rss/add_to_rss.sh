#!/usr/bin/env bash
set -euo pipefail

RSS_FILE="./rss/torrent-rss.xml"
TMP_FILE="./rss/torrent-rss.new.xml"

MAGNET_LINK="${MAGNET_LINK_LOCAL:-magnet:?xt=test123&123}"
# escape &
MAGNET_LINK="${MAGNET_LINK//&/&amp;}"
MAGNET_LINK_GUI="${MAGNET_LINK_LOCAL_GUI:-magnet:?xt=test123&123}"
MAGNET_LINK_GUI="${MAGNET_LINK_GUI//&/&amp;}"
VERSION="${VERSION:-v0.18.0.0}"
VERSION_GUI="${VERSION:-v0.18.0.1}"
TITLE="Monero $VERSION"
TITLE_GUI="Monero GUI $VERSION_GUI"
PUBDATE="$(date -R)"
INFOHASH="${INFOHASH:-123abc123abc}"
INFOHASH_GUI="${INFOHASH_GUI:-123abc123abc}"
TORRENT_URL="${TORRENT_URL:-default_cli_url}"
TORRENT_URL_GUI="${TORRENT_URL_GUI:-default_gui_url}"

NEW_ITEM=$(cat <<EOF
  <item>
    <title>$TITLE</title>
    <link>$TORRENT_URL</link>
    <guid isPermaLink="false">$INFOHASH</guid>
    <pubDate>$PUBDATE</pubDate>
    <description>Multi file torrent for Monero $VERSION</description>
  </item>
  <item>
    <title>$TITLE_GUI</title>
    <link>$TORRENT_URL_GUI</link>
    <guid isPermaLink="false">$INFOHASH_GUI</guid>
    <pubDate>$PUBDATE</pubDate>
    <description>Multi file torrent for Monero GUI $VERSION_GUI</description>
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

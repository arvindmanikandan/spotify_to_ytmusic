#!/bin/bash

set -euo pipefail

SPOTIFY_PLAYLIST_ID="$1"

# Get the playlist name from list_playlists
playlist_name=$(python3 -m spotify2ytmusic list_playlists \
  | awk -v id="$SPOTIFY_PLAYLIST_ID" '$1 == id { $1=""; sub(/^ - /, "", $0); print $0 }' \
  | xargs)

if [ -z "$playlist_name" ]; then
  echo "❌ Playlist ID '$SPOTIFY_PLAYLIST_ID' not found in Spotify list."
  exit 1
fi

echo "🎧 Found Spotify playlist name: '$playlist_name'"

# Create the playlist in YouTube Music
yt_output=$(python3 -m spotify2ytmusic create_playlist "$playlist_name")

yt_playlist_id=$(echo "$yt_output" | grep -o 'PL[^ ]\+')

if [ -z "$yt_playlist_id" ]; then
  echo "❌ Failed to extract YouTube playlist ID from output:"
  echo "$yt_output"
  exit 1
fi

echo "📺 Created YT playlist: '$yt_playlist_id'"

# Copy the tracks from Spotify to YT Music
python3 -m spotify2ytmusic copy_playlist "$SPOTIFY_PLAYLIST_ID" "$yt_playlist_id"


#!/bin/sh

trap 'printf "\n\n Bye!\n\n"; exit 0' INT

echo "\n---------------------------------------------------------------------------\n"
echo "                               IPSW Fetcher"
echo "                   Find & download macOS IPSWs with ease"
echo "   Found a bug? Report it at github.com/homeofhx/mac-script-utils/issues"
echo "\n---------------------------------------------------------------------------\n"

API_URL="https://api.appledb.dev/main.json"
TMP="/tmp/appledb.json"
PARSED="/tmp/appledb_parsed.txt"
echo " Fetching available macOS IPSWs...\n"
curl -s "$API_URL" > "$TMP" || { echo " [ERROR] Failed to fetch IPSW data\n\n Bye!\n\n"; exit 1; }
grep -oE '"https://[^"]*UniversalMac_[^"]*Restore\.ipsw"' "$TMP" | sed 's/"//g' | awk '
!seen[$0]++ {
    n = split($0, a, "/")
    fname = a[n]
    split(fname, b, "_")
    macos = b[2]
    build = b[3]
    split(macos, v, ".")
    major = sprintf("%03d", v[1])
    minor = sprintf("%03d", v[2] ? v[2] : 0)
    patch = sprintf("%03d", v[3] ? v[3] : 0)
    sortkey = major "." minor "." patch
    print sortkey "|" macos "|" build "|" $0
}' | sort -r | cut -d'|' -f2- > "$PARSED"
if [ ! -s "$PARSED" ]; then
    echo " [ERROR] No IPSWs found\n\n Bye!\n\n"
    exit 1
fi
echo " Available macOS IPSWs:\n"
count=0
while IFS='|' read -r macos build url; do
    entry=$(printf "%s (%s)" "$macos" "$build")
    if [ $count -eq 0 ]; then
        printf "  %s" "$entry"
    else
        printf "   |   %s" "$entry"
    fi
    count=$((count + 1))
    if [ $count -eq 4 ]; then
        printf "\n"
        count=0
    fi
done < "$PARSED"
[ $count -ne 0 ] && printf "\n\n"

echo "---------------------------------------------------------------------------\n"
echo " - To download a IPSW, enter that IPSW's build number (e.g. 21G217)"
echo " - To abort, press (Control+C)\n"
while true; do
    printf "Type your response: "
    read -r user_build
    match=$(grep -m1 "^[^|]*|[^|]*|${user_build}|" "$PARSED" 2>/dev/null || \awk -F'|' -v b="$user_build" '$2 == b {print; exit}' "$PARSED")
    if [ -n "$match" ]; then
        break
    else
        echo " Invalid response. Try again.\n"
    fi
done

macos_version=$(echo "$match" | cut -d'|' -f1)
macos_build=$(echo "$match" | cut -d'|' -f2)
dl_url=$(echo "$match" | cut -d'|' -f3)
echo "\n---------------------------------------------------------------------------\n"
echo " You selected: macOS $macos_version ($macos_build)"
echo " - Type (Y) to download the IPSW"
echo " - Type (U) to get the IPSW's download URL"
echo " - To abort, press (Control+C)\n"
while true; do
    printf "Type your response: "
    read -r answer
    case "$answer" in
        [Yy])
            break
            ;;
        [Uu])
            echo "\n Download URL: $dl_url\n"
            ;;
        *)
            echo " Invalid response. Try again.\n"
            ;;
    esac
done

DL_DIR="$HOME/Downloads"
mkdir -p "$DL_DIR"
filename="UniversalMac_${macos_version}_${macos_build}_Restore.ipsw"
dl_dest="$DL_DIR/$filename"
echo "\n---------------------------------------------------------------------------\n"
echo " Now Downloading macOS $macos_version ($macos_build)..."
echo " You can cancel the download at any time by pressing (Control+C)\n"
if curl -L --progress-bar -o "$dl_dest" "$dl_url"; then
    echo "\n Download complete!"
    echo " The downloaded IPSW is at: $dl_dest\n"
else
    echo "\n [ERROR] Download failed!\n"
    rm -f "$dl_dest"
    exit 1
fi
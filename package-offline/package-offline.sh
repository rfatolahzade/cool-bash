#!/bin/bash
# Script to download package and all dependencies for offline installation
# At least you should run sudo dpkg -i *.deb in downloaded package dir , dir name PACKAGENAME-offline-$date

if [ $# -eq 0 ]; then
    echo "Usage: $0 <package-name>"
    exit 1
fi

PACKAGE=$1
DIR="${PACKAGE}-offline-$(date +%Y%m%d)"

echo "Creating directory: $DIR"
mkdir -p $DIR
cd $DIR

echo "Downloading package: $PACKAGE"
apt-get download $PACKAGE

echo "Downloading dependencies..."
apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $PACKAGE | grep "^\w" | xargs apt-get download 2>/dev/null

echo "Download complete!"
echo "Packages downloaded: $(ls *.deb | wc -l)"
echo "Transfer the entire '$DIR' directory to your offline machine"
echo "Then run: sudo dpkg -i *.deb"

cd ..
ls -la $DIR/

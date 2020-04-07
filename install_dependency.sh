#!/bin/bash
set -eu
echo "Build Clash core"
cd ClashX/goClash
python3 build_clash.py
echo "Pod install"
cd ../..
pod install
echo "delete old files"
rm -f ./ClashX/Resources/Country.mmdb
rm -rf ./ClashX/Resources/dashboard
rm -f GeoLite2-Country.*
echo "install mmdb"
wget https://static.clash.to/GeoIP2/GeoIP2-Country.mmdb
mv GeoIP2-Country.mmdb ./ClashX/Resources/Country.mmdb
echo "install dashboard"
cd ClashX/Resources
git clone -b gh-pages https://github.com/Dreamacro/clash-dashboard.git dashboard

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
wget https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb
mv Country.mmdb ./ClashX/Resources/Country.mmdb
echo "install dashboard"
cd ClashX/Resources
git clone -b gh-pages https://github.com/Dreamacro/clash-dashboard.git dashboard

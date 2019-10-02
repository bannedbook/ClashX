#!/bin/bash
set -eu
echo "delete old files"
rm -f ./ClashX/Resources/Country.mmdb
rm -rf ./ClashX/Resources/dashboard
rm -f GeoLite2-Country.*
echo "install mmdb"
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
tar -zxvf GeoLite2-Country.tar.gz
mv GeoLite2-Country_*/GeoLite2-Country.mmdb ./ClashX/Resources/Country.mmdb
rm GeoLite2-Country.tar.gz
rm -r GeoLite2-Country_*
echo "install dashboard"
cd ClashX/Resources
git clone -b gh-pages https://github.com/Dreamacro/clash-dashboard.git dashboard
cd ..
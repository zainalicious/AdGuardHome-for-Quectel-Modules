#!/bin/sh
# Installer AdGuardHome for Quectel Modules - Final
# https://github.com/zainalicious/AdGuardHome-For-Quectel-Modules

REPO="https://raw.githubusercontent.com/zainalicious/AdGuardHome-For-Quectel-Modules/main"
DNSMASQ_CONF="/etc/data/dnsmasq.conf"

set -e

echo "[1/4] Install AdGuardHome dari Entware..."
opkg update
opkg install adguardhome-go

echo "[2/4] Download file dari repo..."
if command -v curl >/dev/null 2>&1; then
  curl -L -o /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
else
  wget -O /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
fi

chmod +x /opt/etc/init.d/S99AdGuardHome

echo "[3/4] Konfigurasi dnsmasq..."
touch $DNSMASQ_CONF
# hapus dulu biar tidak duplikat kalau install ulang
sed -i '/^no-resolv/d' $DNSMASQ_CONF
sed -i '/^port=0/d' $DNSMASQ_CONF
sed -i '/^port=54/d' $DNSMASQ_CONF
sed -i '/^server=127.0.0.1/d' $DNSMASQ_CONF
echo "no-resolv" >> $DNSMASQ_CONF
echo "server=127.0.0.1" >> $DNSMASQ_CONF

echo "[4/4] Start service..."
/opt/etc/init.d/S99AdGuardHome start

echo ""
echo "[OK] Selesai!"
echo "  Binary : /opt/bin/AdGuardHome (dari opkg)"
echo "  Init   : /opt/etc/init.d/S99AdGuardHome (dari repo)"
echo "  Config : /opt/etc/AdGuardHome/AdGuardHome.yaml (dari repo)"
echo ""
tail -3 $DNSMASQ_CONF
/opt/etc/init.d/S99AdGuardHome check

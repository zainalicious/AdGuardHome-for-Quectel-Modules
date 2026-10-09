#!/bin/sh
# Installer AdGuardHome for Quectel Modules - Final
# https://github.com/zainalicious/AdGuardHome-For-Quectel-Modules

REPO="https://raw.githubusercontent.com/zainalicious/AdGuardHome-For-Quectel-Modules/main"
DNSMASQ_CONF="/etc/data/dnsmasq.conf"

set -e

echo "[1/5] Install AdGuardHome dari Entware..."
opkg update
opkg install adguardhome-go

echo "[2/5] hapus file init bawaan..."
rm -f /opt/etc/init.d/S99adguardhome

echo "[3/5] Download file dari repo..."
if command -v curl >/dev/null 2>&1; then
  curl -L -o /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
  curl -L -o /opt/etc/init.d/S99adguardhome $REPO/opt/etc/init.d/S99adguardhome
else
  wget -O /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
  wget -O /opt/etc/init.d/S99adguardhome $REPO/opt/etc/init.d/S99adguardhome
fi

chmod +x /opt/etc/init.d/S99adguardhome

echo "[4/5] Konfigurasi dnsmasq..."
touch $DNSMASQ_CONF
# hapus dulu biar tidak duplikat kalau install ulang
sed -i '/^no-resolv/d' $DNSMASQ_CONF
sed -i '/^port=0/d' $DNSMASQ_CONF
sed -i '/^port=54/d' $DNSMASQ_CONF
sed -i '/^server=127.0.0.1/d' $DNSMASQ_CONF
sed -i '/^server=::1/d' $DNSMASQ_CONF
echo "no-resolv" >> $DNSMASQ_CONF
echo "server=127.0.0.1" >> $DNSMASQ_CONF
echo "server=::1" >> $DNSMASQ_CONF

echo "[5/5] Start service..."
/opt/etc/init.d/S99adguardhome start

echo ""
echo "[OK] Selesai!"
echo "  Binary : /opt/bin/AdGuardHome (dari opkg)"
echo "  Init   : /opt/etc/init.d/S99adguardhome (dari repo)"
echo "  Config : /opt/etc/AdGuardHome/AdGuardHome.yaml (dari repo)"
echo ""
tail -10 $DNSMASQ_CONF
/opt/etc/init.d/S99adguardhome check
cat /etc/resolv.conf

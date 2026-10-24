#!/bin/sh
# Installer AdGuardHome for Quectel Modules - Final
# https://github.com/zainalicious/AdGuardHome-For-Quectel-Modules

REPO="https://raw.githubusercontent.com/zainalicious/AdGuardHome-For-Quectel-Modules/main"
set -e

echo "[1/4] Install AdGuardHome dari Entware..."
opkg update
opkg install cron
opkg install adguardhome-go

echo "[2/4] Download file dari repo..."
mkdir -p /opt/etc/AdGuardHome
mkdir -p /usrdata/scripts
if command -v curl >/dev/null 2>&1; then
  curl -L -o /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
  curl -L -o /usrdata/scripts/watch_agh.sh $REPO/usrdata/scripts/watch_agh.sh
else
  wget -O /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
  wget -O /usrdata/scripts/watch_agh.sh $REPO/usrdata/scripts/watch_agh.sh
fi

chmod +x /usrdata/scripts/watch_agh.sh

echo "[3/4] Konfigurasi Crontab..."
# hapus duplikat watch_agh jika ada
sed -i '/watch_agh.sh/d' /opt/etc/crontab 2>/dev/null || true
# menambahkan cron job watch_agh.sh
printf "* * * * * root /usrdata/scripts/watch_agh.sh\n\n" >> /opt/etc/crontab
/opt/etc/init.d/S10cron start

echo "[4/4] Start service..."
/opt/etc/init.d/S99adguardhome start

echo ""
echo "[OK] Selesai!"
echo "  Binary : /opt/bin/AdGuardHome (dari opkg)"
echo "  Config : /opt/etc/AdGuardHome/AdGuardHome.yaml (dari repo)"
echo "  Watch  : /usrdata/scripts/watch_agh.sh"
echo ""
/opt/etc/init.d/S99adguardhome check
/opt/etc/init.d/S10cron check
echo "--- /opt/etc/crontab ---"
cat /opt/etc/crontab

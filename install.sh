#!/bin/sh
# Installer AdGuardHome for Quectel Modules - Final
# https://github.com/zainalicious/AdGuardHome-For-Quectel-Modules

REPO="https://raw.githubusercontent.com/zainalicious/AdGuardHome-For-Quectel-Modules/main"
set -e

echo "[1/5] Install AdGuardHome dari Entware..."
opkg update
opkg install cron
opkg install adguardhome-go

echo "[2/5] hapus file init bawaan..."
rm -f /opt/etc/init.d/S99adguardhome

echo "[3/5] Download file dari repo..."
if command -v curl >/dev/null 2>&1; then
  curl -L -o /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
  curl -L -o /opt/etc/init.d/S99adguardhome $REPO/opt/etc/init.d/S99adguardhome
  curl -L -o /usrdata/scripts/watch_agh.sh $REPO/usrdata/scripts/watch_agh.sh
else
  wget -O /opt/etc/AdGuardHome/AdGuardHome.yaml $REPO/opt/etc/AdGuardHome/AdGuardHome.yaml
  wget -O /opt/etc/init.d/S99adguardhome $REPO/opt/etc/init.d/S99adguardhome
  wget -O /usrdata/scripts/watch_agh.sh $REPO/usrdata/scripts/watch_agh.sh
fi

chmod +x /opt/etc/init.d/S99adguardhome
chmod +x /usrdata/scripts/watch_agh.sh

echo "[4/5] Konfigurasi Crontab..."
# hapus duplikat watch_agh jika ada
sed -i '/watch_agh.sh/d' /opt/etc/crontab 2>/dev/null || true
echo "" >> /opt/etc/crontab
# menambahkan cron job watch_agh.sh
printf "* * * * * root /usrdata/scripts/watch_agh.sh\n\n" >> /opt/etc/crontab
/opt/etc/init.d/S10cron restart

echo "[5/5] Start service..."
/opt/etc/init.d/S99adguardhome start

echo ""
echo "[OK] Selesai!"
echo "  Binary : /opt/bin/AdGuardHome (dari opkg)"
echo "  Init   : /opt/etc/init.d/S99adguardhome (dari repo)"
echo "  Config : /opt/etc/AdGuardHome/AdGuardHome.yaml (dari repo)"
echo "  Watch  : /usrdata/scripts/watch_agh.sh"
echo ""
/opt/etc/init.d/S99adguardhome check
/opt/etc/init.d/S10cron check
echo "--- /opt/etc/crontab ---"
cat -A /opt/etc/crontab
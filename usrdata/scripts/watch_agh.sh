#!/bin/sh
# /opt/etc/crontab
# * * * * * root /usrdata/script/watch_agh.sh

AGH_INIT="/opt/etc/init.d/S99adguardhome"
RESOLV="/etc/resolv.conf"
LOCKDIR="/tmp/watch-agh.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
    exit 0
fi

write_resolv_agh() {
    echo "nameserver 127.0.0.1
nameserver ::1" > "${RESOLV}.tmp"
    mv -f "${RESOLV}.tmp" "$RESOLV"
}

is_agh_running() {
    /bin/pidof AdGuardHome >/dev/null 2>&1
}

# ================= TIER 1 =================
if ! is_agh_running; then
    $AGH_INIT start >/dev/null 2>&1
    sleep 3
    # Cek lagi, kalau masih gagal jangan paksa resolv.conf ke AGH
    if ! is_agh_running; then
        rmdir "$LOCKDIR"
        exit 1
    fi
    rmdir "$LOCKDIR"
    exit 0
fi

# ================= TIER 2 =================
# AGH hidup, cek resolv.conf
if ! /bin/grep -q "^nameserver 127.0.0.1" "$RESOLV" 2>/dev/null; then
    write_resolv_agh
    rmdir "$LOCKDIR"
    exit 0
fi

if ! /bin/grep -q "^nameserver ::1" "$RESOLV" 2>/dev/null; then
    write_resolv_agh
    rmdir "$LOCKDIR"
    exit 0
fi

# OK, cleanup lock
rmdir "$LOCKDIR"
exit 0

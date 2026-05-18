#!/bin/sh
# ycust_autologin.sh - Campus Network Auto-Login Daemon
# Detection: Dr.COM login endpoint returns:
#   error5 + result:1 = already online (silent)
#   result:1 only      = just logged in (log OK)
#   result:0           = auth failed (log FAIL)
#   empty              = portal unreachable (log WARN)

PHY_IFACE="phy0-sta0"

logger -t ycustlogin "[START] Daemon started on $PHY_IFACE"

while true; do
    ENABLE=$(uci -q get ycustlogin.main.enable)
    USER=$(uci -q get ycustlogin.main.username)
    PASS=$(uci -q get ycustlogin.main.password)
    INTERVAL=$(uci -q get ycustlogin.main.check_interval)
    [ -z "$INTERVAL" ] && INTERVAL=60
    [ "$ENABLE" != "1" ] && sleep 60 && continue
    [ -z "$USER" ] && sleep 60 && continue
    [ -z "$PASS" ] && sleep 60 && continue

    URL="http://10.10.10.3/drcom/login?callback=dr1004&DDDDD=${USER}&upass=${PASS}&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn&jsVersion=4.1.3&v=4359&lang=zh"
    RES=$(curl -s --interface "$PHY_IFACE" -m 5 "$URL" 2>/dev/null)

    if [ -z "$RES" ]; then
        logger -t ycustlogin "[WARN] Portal unreachable"
    elif echo "$RES" | grep -q 'error5'; then
        :  # Already online, no action needed
    elif echo "$RES" | grep -q '"result":1'; then
        logger -t ycustlogin "[OK] Login succeeded for $USER"
    elif echo "$RES" | grep -q '"result":0'; then
        logger -t ycustlogin "[FAIL] Auth rejected"
    else
        logger -t ycustlogin "[WARN] Unexpected: ${RES:0:80}"
    fi

    sleep "$INTERVAL"
done

